import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/unstable/ffi_bindings.dart' as native;

import 'tarot_backup_database_inspector.dart';
import 'tarot_backup_path_contract.dart';

typedef TarotOnlineBackupRunner =
    Future<void> Function(Database source, Database target, Duration deadline);
typedef TarotBeforeOnlineBackup = Future<void> Function();
typedef TarotBackupBoundaryHook = Future<void> Function();
typedef TarotSqliteDatabaseOpen =
    Database Function(String path, OpenMode mode, String role);
typedef TarotSqliteDatabaseClose =
    void Function(Database database, String role);
typedef TarotSqliteFileDelete = Future<void> Function(File file);

final class TarotSqliteOnlineBackupService {
  const TarotSqliteOnlineBackupService({
    this.onlineBackup,
    this.beforeOnlineBackup,
    this.afterOnlineBackupBeforeVerification,
    this.beforeFailedTargetCleanup,
    this.beforeTargetVacuum,
    this.beforePostSanitationInspection,
    this.databaseOpen = _openDatabase,
    this.databaseClose = _closeDatabase,
    this.deleteFile = _deleteFile,
    this.inspector = const TarotBackupDatabaseInspector(),
  });

  static const Duration defaultDeadline = Duration(seconds: 120);

  final TarotOnlineBackupRunner? onlineBackup;
  final TarotBeforeOnlineBackup? beforeOnlineBackup;
  final TarotBackupBoundaryHook? afterOnlineBackupBeforeVerification;
  final TarotBackupBoundaryHook? beforeFailedTargetCleanup;
  final TarotBackupBoundaryHook? beforeTargetVacuum;
  final TarotBackupBoundaryHook? beforePostSanitationInspection;
  final TarotSqliteDatabaseOpen databaseOpen;
  final TarotSqliteDatabaseClose databaseClose;
  final TarotSqliteFileDelete deleteFile;
  final TarotBackupDatabaseInspector inspector;

  Future<TarotSanitizedSnapshotResult> createSnapshot({
    required String sourceDatabasePath,
    required String targetDatabasePath,
    required ResolvedBackupRecoveryPaths paths,
    Duration deadline = defaultDeadline,
  }) async {
    paths.validateSourceDatabasePath(sourceDatabasePath);
    paths.validateTargetSnapshotPath(targetDatabasePath);
    _rejectProtectedRuntimePath(sourceDatabasePath);
    if (_samePath(sourceDatabasePath, targetDatabasePath) ||
        deadline <= Duration.zero) {
      throw const TarotSqliteBackupException('invalid_snapshot_request');
    }
    final targetFile = File(targetDatabasePath);
    if (targetFile.existsSync()) {
      throw const TarotSqliteBackupException('target_already_exists');
    }

    await paths.requireSafeAncestry(sourceDatabasePath);
    await paths.requireSafeAncestry(targetDatabasePath);
    final sourceEvidence = inspector.inspectVerified(
      sourceDatabasePath,
      policy: TarotDatabaseInspectionPolicy.normalReadOnlySource,
    );
    await paths.requireSafeAncestry(sourceDatabasePath);
    Database? source;
    Database? target;
    TarotSqliteBackupException? backupFailure;
    try {
      source = databaseOpen(sourceDatabasePath, OpenMode.readOnly, 'source');
      await _requireTargetBoundary(
        targetDatabasePath,
        paths,
        mainMustExist: false,
        sidecarsMustBeAbsent: true,
      );
      target = databaseOpen(
        targetDatabasePath,
        OpenMode.readWriteCreate,
        'backup_target',
      );
      await beforeOnlineBackup?.call();
      await _requireTargetBoundary(
        targetDatabasePath,
        paths,
        mainMustExist: true,
      );
      if (onlineBackup == null) {
        await _runInstalledOnlineBackup(source, target, deadline);
      } else {
        await onlineBackup!(source, target, deadline).timeout(deadline);
      }
    } on TimeoutException {
      backupFailure = const TarotSqliteBackupException('snapshot_timeout');
    } on TarotSqliteBackupException catch (error) {
      backupFailure = error;
    } on Object {
      backupFailure = const TarotSqliteBackupException('snapshot_failed');
    }
    final backupClose = _closeDatabases(<_OwnedDatabase>[
      if (target != null) _OwnedDatabase(target, 'backup_target'),
      if (source != null) _OwnedDatabase(source, 'source'),
    ], databaseClose);
    if (!backupClose.allResolved) {
      throw TarotSqliteBackupException(
        backupFailure?.code ?? 'database_close_failed',
        closeUnresolved: true,
      );
    }
    if (backupFailure != null) {
      await _deleteInvalidTarget(
        targetDatabasePath,
        paths,
        beforeFailedTargetCleanup,
        deleteFile,
      );
      throw backupFailure;
    }

    var cleanupAllowed = true;
    try {
      await afterOnlineBackupBeforeVerification?.call();
      await _requireTargetBoundary(targetDatabasePath, paths);
      final beforeSanitation = inspector.inspectVerified(
        targetDatabasePath,
        policy: TarotDatabaseInspectionPolicy.immutableReadOnlyFrozenTarget,
        requireAcceptableSidecars: true,
      );
      await _requireTargetBoundary(targetDatabasePath, paths);
      if (!sourceEvidence.sameLogicalState(beforeSanitation)) {
        throw const TarotSqliteBackupException('snapshot_logical_mismatch');
      }
      Database? sanitation;
      TarotSqliteBackupException? sanitationFailure;
      try {
        await _requireTargetBoundary(targetDatabasePath, paths);
        sanitation = databaseOpen(
          targetDatabasePath,
          OpenMode.readWriteCreate,
          'sanitation',
        );
        await _requireTargetBoundary(targetDatabasePath, paths);
        sanitation.execute('PRAGMA journal_mode = DELETE');
        await beforeTargetVacuum?.call();
        await _requireTargetBoundary(targetDatabasePath, paths);
        sanitation.execute('VACUUM');
      } on TarotSqliteBackupException catch (error) {
        sanitationFailure = error;
      } on Object {
        sanitationFailure = const TarotSqliteBackupException(
          'target_sanitation_failed',
        );
      }
      final sanitationClose = _closeDatabases(<_OwnedDatabase>[
        if (sanitation != null) _OwnedDatabase(sanitation, 'sanitation'),
      ], databaseClose);
      if (!sanitationClose.allResolved) {
        cleanupAllowed = false;
        throw TarotSqliteBackupException(
          sanitationFailure?.code ?? 'database_close_failed',
          closeUnresolved: true,
        );
      }
      if (sanitationFailure != null) throw sanitationFailure;
      await beforePostSanitationInspection?.call();
      await _requireTargetBoundary(targetDatabasePath, paths);
      final afterSanitation = inspector.inspectVerified(
        targetDatabasePath,
        policy: TarotDatabaseInspectionPolicy.immutableReadOnlyFrozenTarget,
        requireAcceptableSidecars: true,
      );
      await _requireTargetBoundary(targetDatabasePath, paths);
      if (!beforeSanitation.sameLogicalState(afterSanitation)) {
        throw const TarotSqliteBackupException(
          'sanitation_changed_logical_state',
        );
      }
      if (afterSanitation.freelistCount != 0) {
        throw const TarotSqliteBackupException('sanitation_freelist_nonzero');
      }
      if (afterSanitation.hasUnexpectedNonEmptySidecar) {
        throw const TarotSqliteBackupException('target_sidecar_nonempty');
      }
      return TarotSanitizedSnapshotResult(
        sourceEvidence: sourceEvidence,
        beforeSanitation: beforeSanitation,
        afterSanitation: afterSanitation,
      );
    } on TarotSqliteBackupException catch (error) {
      cleanupAllowed = cleanupAllowed && !error.closeUnresolved;
      if (cleanupAllowed) {
        await _deleteInvalidTarget(
          targetDatabasePath,
          paths,
          beforeFailedTargetCleanup,
          deleteFile,
        );
      }
      rethrow;
    } on TarotBackupInspectionException catch (error) {
      cleanupAllowed = cleanupAllowed && !error.closeUnresolved;
      if (cleanupAllowed) {
        await _deleteInvalidTarget(
          targetDatabasePath,
          paths,
          beforeFailedTargetCleanup,
          deleteFile,
        );
      }
      rethrow;
    } on Object {
      if (cleanupAllowed) {
        await _deleteInvalidTarget(
          targetDatabasePath,
          paths,
          beforeFailedTargetCleanup,
          deleteFile,
        );
      }
      throw const TarotSqliteBackupException('target_verification_failed');
    }
  }

  static Future<void> _runInstalledOnlineBackup(
    Database source,
    Database target,
    Duration deadline,
  ) async {
    if (!Platform.isWindows) {
      throw const TarotSqliteBackupException('unsupported_backup_platform');
    }
    final stopwatch = Stopwatch()..start();
    final databaseName = _WindowsUtf8.allocate('main');
    Pointer<native.sqlite3_backup> backup = nullptr;
    TarotSqliteBackupException? failure;
    var finishResult = 0;
    try {
      backup = native.sqlite3_backup_init(
        target.handle.cast<native.sqlite3>(),
        databaseName.pointer.cast<native.sqlite3_char>(),
        source.handle.cast<native.sqlite3>(),
        databaseName.pointer.cast<native.sqlite3_char>(),
      );
      if (backup == nullptr) {
        throw const TarotSqliteBackupException('backup_init_failed');
      }
      while (true) {
        if (stopwatch.elapsed >= deadline) {
          throw const TarotSqliteBackupException('snapshot_timeout');
        }
        final result = native.sqlite3_backup_step(backup, 32);
        if (result == _sqliteDone) break;
        if (result == _sqliteOk) continue;
        if (result == _sqliteBusy || result == _sqliteLocked) {
          final remaining = deadline - stopwatch.elapsed;
          if (remaining <= Duration.zero) {
            throw const TarotSqliteBackupException('snapshot_timeout');
          }
          await Future<void>.delayed(
            remaining < const Duration(milliseconds: 25)
                ? remaining
                : const Duration(milliseconds: 25),
          );
          continue;
        }
        throw const TarotSqliteBackupException('backup_step_failed');
      }
    } on TarotSqliteBackupException catch (error) {
      failure = error;
    } on Object {
      failure = const TarotSqliteBackupException('snapshot_failed');
    } finally {
      if (backup != nullptr) {
        finishResult = native.sqlite3_backup_finish(backup);
      }
      databaseName.free();
      stopwatch.stop();
    }
    if (failure != null) throw failure;
    if (finishResult != _sqliteOk) {
      throw const TarotSqliteBackupException('backup_finish_failed');
    }
  }
}

final class TarotSanitizedSnapshotResult {
  const TarotSanitizedSnapshotResult({
    required this.sourceEvidence,
    required this.beforeSanitation,
    required this.afterSanitation,
  });

  final TarotDatabaseEvidence sourceEvidence;
  final TarotDatabaseEvidence beforeSanitation;
  final TarotDatabaseEvidence afterSanitation;
}

final class TarotSqliteBackupException implements Exception {
  const TarotSqliteBackupException(this.code, {this.closeUnresolved = false});
  final String code;
  final bool closeUnresolved;

  @override
  String toString() => 'TarotSqliteBackupException($code)';
}

Future<void> _requireTargetBoundary(
  String path,
  ResolvedBackupRecoveryPaths paths, {
  bool mainMustExist = true,
  bool sidecarsMustBeAbsent = false,
}) async {
  paths.validateTargetSnapshotPath(path);
  await paths.requireSafeAncestry(path);
  final mainType = FileSystemEntity.typeSync(path, followLinks: false);
  if ((mainMustExist && mainType != FileSystemEntityType.file) ||
      (!mainMustExist && mainType != FileSystemEntityType.notFound)) {
    throw const TarotSqliteBackupException('target_not_regular_file');
  }
  for (final sidecarPath in _targetSidecarPaths(path)) {
    paths.validateTargetCleanupPath(sidecarPath, path);
    await paths.requireSafeAncestry(sidecarPath);
    final type = FileSystemEntity.typeSync(sidecarPath, followLinks: false);
    if (type == FileSystemEntityType.notFound) continue;
    if (sidecarsMustBeAbsent || type != FileSystemEntityType.file) {
      throw const TarotSqliteBackupException('target_sidecar_unsafe');
    }
    if (File(sidecarPath).lengthSync() != 0) {
      throw const TarotSqliteBackupException('target_sidecar_nonempty');
    }
  }
}

Future<void> _deleteInvalidTarget(
  String path,
  ResolvedBackupRecoveryPaths paths,
  TarotBackupBoundaryHook? beforeCleanup,
  TarotSqliteFileDelete deleteFile,
) async {
  await beforeCleanup?.call();
  for (final candidate in <String>[path]) {
    try {
      paths.validateTargetCleanupPath(candidate, path);
      await paths.requireSafeAncestry(candidate);
    } on Object {
      continue;
    }
    final file = File(candidate);
    if (FileSystemEntity.typeSync(candidate, followLinks: false) ==
        FileSystemEntityType.file) {
      try {
        await deleteFile(file);
      } on FileSystemException {
        // The caller still receives failure; no invalid artifact is finalized.
      }
    }
  }
}

List<String> _targetSidecarPaths(String path) => <String>[
  '$path-wal',
  '$path-shm',
  '$path-journal',
];

final class _OwnedDatabase {
  const _OwnedDatabase(this.database, this.role);

  final Database database;
  final String role;
}

final class _CloseResult {
  const _CloseResult({required this.allResolved});

  final bool allResolved;
}

_CloseResult _closeDatabases(
  List<_OwnedDatabase> databases,
  TarotSqliteDatabaseClose closeDatabase,
) {
  var allResolved = true;
  for (final owned in databases) {
    try {
      closeDatabase(owned.database, owned.role);
    } on Object {
      allResolved = false;
    }
  }
  return _CloseResult(allResolved: allResolved);
}

Database _openDatabase(String path, OpenMode mode, String _) =>
    sqlite3.open(path, mode: mode);

void _closeDatabase(Database database, String _) => database.close();

Future<void> _deleteFile(File file) => file.delete();

void _rejectProtectedRuntimePath(String path) {
  final normalized = path.replaceAll('\\', '/').toLowerCase();
  const protectedFragments = <String>[
    '/rinvitalcenter/rynuniverseos/development/runtime/ryn_universe_os_core_dev.sqlite',
    '/rinvitalcenter/rynuniverseos/development/qa/core_tarot_self_reading_persistence1/',
    '/rinvitalcenter/rynuniverseos/production/',
    '/rinvitalcenter/rynuniverseos/development/qa/core_tarot_backup_recovery_v0_2/',
  ];
  if (protectedFragments.any(normalized.contains)) {
    throw const TarotSqliteBackupException('protected_source_path');
  }
}

bool _samePath(String left, String right) =>
    File(left).absolute.path.toLowerCase() ==
    File(right).absolute.path.toLowerCase();

const int _sqliteOk = 0;
const int _sqliteBusy = 5;
const int _sqliteLocked = 6;
const int _sqliteDone = 101;

final class _WindowsUtf8 {
  _WindowsUtf8._(this.pointer);

  final Pointer<Uint8> pointer;

  static final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');
  static final Pointer<Void> Function() _getProcessHeap = _kernel32
      .lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
        'GetProcessHeap',
      );
  static final Pointer<Uint8> Function(Pointer<Void>, int, int) _heapAlloc =
      _kernel32.lookupFunction<
        Pointer<Uint8> Function(Pointer<Void>, Uint32, IntPtr),
        Pointer<Uint8> Function(Pointer<Void>, int, int)
      >('HeapAlloc');
  static final int Function(Pointer<Void>, int, Pointer<Void>) _heapFree =
      _kernel32.lookupFunction<
        Int32 Function(Pointer<Void>, Uint32, Pointer<Void>),
        int Function(Pointer<Void>, int, Pointer<Void>)
      >('HeapFree');

  static _WindowsUtf8 allocate(String value) {
    final bytes = value.codeUnits;
    final pointer = _heapAlloc(_getProcessHeap(), 0, bytes.length + 1);
    if (pointer == nullptr) {
      throw const TarotSqliteBackupException('native_allocation_failed');
    }
    for (var index = 0; index < bytes.length; index++) {
      pointer[index] = bytes[index];
    }
    pointer[bytes.length] = 0;
    return _WindowsUtf8._(pointer);
  }

  void free() {
    _heapFree(_getProcessHeap(), 0, pointer.cast<Void>());
  }
}
