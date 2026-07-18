import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../../core/persistence/runtime_data_profile.dart';
import '../../application/tarot_runtime_controller.dart';
import '../domain/tarot_restore_candidate.dart';
import '../domain/tarot_restore_operation_result.dart';
import '../infrastructure/tarot_backup_path_contract.dart';
import '../infrastructure/tarot_restore_candidate_validator.dart';
import 'tarot_backup_snapshot_coordinator.dart';
import 'tarot_restore_coordinator.dart';

enum TarotBackupRestoreActionStatus {
  idle,
  selectingRestore,
  restoreReady,
  backingUp,
  restoring,
  succeeded,
  failed,
  fatalRecoveryRequired,
}

typedef TarotBackupAction = Future<String> Function();
typedef TarotRestoreDirectorySelector = Future<String?> Function();
typedef TarotRestoreValidationAction =
    Future<TarotRestoreCandidate> Function(String packagePath);
typedef TarotRestoreAction =
    Future<TarotRestoreOperationResult> Function(String packagePath);

final class TarotBackupRestoreActionController extends ChangeNotifier {
  factory TarotBackupRestoreActionController({
    required TarotBackupAction createBackup,
    required TarotRestoreDirectorySelector selectRestoreDirectory,
    required TarotRestoreValidationAction validateRestoreCandidate,
    required TarotRestoreAction restore,
  }) => TarotBackupRestoreActionController._internal(
    createBackup: createBackup,
    selectRestoreDirectory: selectRestoreDirectory,
    validateRestoreCandidate: validateRestoreCandidate,
    restore: restore,
  );

  TarotBackupRestoreActionController._internal({
    required this._createBackup,
    required this._selectRestoreDirectory,
    required this._validateRestoreCandidate,
    required this._restore,
  });

  factory TarotBackupRestoreActionController.synthetic({
    required TarotRuntimeController runtimeController,
    required RynRuntimeDataPathContract pathContract,
    TarotRestoreDirectorySelector? selectRestoreDirectory,
  }) {
    final validator = TarotRestoreCandidateValidator();
    final backupCoordinator = TarotBackupSnapshotCoordinator(
      operationIdGenerator: _operationId,
    );
    final restoreCoordinator = TarotRestoreCoordinator(
      candidateValidator: validator,
      backupCoordinator: backupCoordinator,
    );

    Future<
      ({RynResolvedDatabasePath runtime, ResolvedBackupRecoveryPaths paths})
    >
    resolve() async {
      if (runtimeController.runtimeDataMode !=
          RynRuntimeDataMode.tarotBackupRecoveryQa) {
        throw StateError('backup and restore require synthetic QA mode');
      }
      final runtime = await pathContract.requireRuntimeOpenableMode(
        RynRuntimeDataMode.tarotBackupRecoveryQa,
      );
      _requireUnderSystemTemp(runtime.profileRootPath);
      final backupRootPath = _syntheticBackupRoot(runtime);
      await Directory(backupRootPath).create(recursive: true);
      final paths = TarotBackupPathContract(
        sourceRootPath: runtime.runtimeDirectoryPath,
        backupRootPath: backupRootPath,
        protectedRootPaths: const <String>[],
      ).resolve();
      return (runtime: runtime, paths: paths);
    }

    return TarotBackupRestoreActionController(
      createBackup: () async {
        final value = await resolve();
        final package = await backupCoordinator.createVerifiedBackup(
          sourceDatabasePath: value.runtime.databasePath,
          resolvedPaths: value.paths,
          sourceProfileEvidence:
              const TarotBackupSourceProfileEvidence.syntheticQa(),
          applicationVersion: '1.0.0',
        );
        return package.finalDirectory.absolute.path;
      },
      selectRestoreDirectory:
          selectRestoreDirectory ?? _selectRynBackupDirectory,
      validateRestoreCandidate: (packagePath) async {
        _requireUnderSystemTemp(packagePath);
        return validator.validate(packagePath);
      },
      restore: (packagePath) async {
        final value = await resolve();
        _requireUnderSystemTemp(packagePath);
        final result = await restoreCoordinator.restore(
          candidatePackagePath: packagePath,
          liveDatabasePath: value.runtime.databasePath,
          resolvedPaths: value.paths,
          sourceProfileEvidence:
              const TarotBackupSourceProfileEvidence.syntheticQa(),
          applicationVersion: '1.0.0',
          operationId: _operationId(),
          lifecycle: runtimeController.syntheticRestoreLifecycle(value.runtime),
        );
        await runtimeController.bootstrap();
        return result;
      },
    );
  }

  final TarotBackupAction _createBackup;
  final TarotRestoreDirectorySelector _selectRestoreDirectory;
  final TarotRestoreValidationAction _validateRestoreCandidate;
  final TarotRestoreAction _restore;

  TarotBackupRestoreActionStatus _status = TarotBackupRestoreActionStatus.idle;
  TarotRestoreCandidate? _pendingCandidate;
  String? _message;
  String? _outputPath;
  String? _evidencePath;
  String? _failureCode;

  TarotBackupRestoreActionStatus get status => _status;
  TarotRestoreCandidate? get pendingCandidate => _pendingCandidate;
  String? get message => _message;
  String? get outputPath => _outputPath;
  String? get evidencePath => _evidencePath;
  String? get failureCode => _failureCode;
  bool get isBusy => switch (_status) {
    TarotBackupRestoreActionStatus.selectingRestore ||
    TarotBackupRestoreActionStatus.backingUp ||
    TarotBackupRestoreActionStatus.restoring => true,
    _ => false,
  };

  Future<void> createBackup() async {
    if (isBusy) return;
    _begin(TarotBackupRestoreActionStatus.backingUp);
    try {
      _outputPath = await _createBackup();
      _status = TarotBackupRestoreActionStatus.succeeded;
      _message = '백업을 만들었어요.';
    } on Object catch (error) {
      _fail('백업을 만들지 못했어요.', _errorCode(error));
    }
    notifyListeners();
  }

  Future<bool> selectRestoreCandidate() async {
    if (isBusy) return false;
    _begin(TarotBackupRestoreActionStatus.selectingRestore);
    try {
      final selected = await _selectRestoreDirectory();
      if (selected == null || selected.trim().isEmpty) {
        _reset();
        notifyListeners();
        return false;
      }
      _pendingCandidate = await _validateRestoreCandidate(selected);
      _status = TarotBackupRestoreActionStatus.restoreReady;
      notifyListeners();
      return true;
    } on Object catch (error) {
      _fail('선택한 백업을 확인하지 못했어요.', _errorCode(error));
      notifyListeners();
      return false;
    }
  }

  Future<void> restoreSelected() async {
    final candidate = _pendingCandidate;
    if (isBusy || candidate == null) return;
    _begin(TarotBackupRestoreActionStatus.restoring, keepCandidate: true);
    try {
      final result = await _restore(candidate.packagePath);
      _outputPath = result.safetyBackupPackagePath;
      _evidencePath = result.preservedEvidencePath;
      _failureCode = result.failureCode;
      if (result.status == TarotRestoreOperationStatus.succeeded) {
        _status = TarotBackupRestoreActionStatus.succeeded;
        _message = '백업에서 복원했어요.';
      } else if (result.status ==
          TarotRestoreOperationStatus.fatalRecoveryRequired) {
        _status = TarotBackupRestoreActionStatus.fatalRecoveryRequired;
        _message = '자동 복구를 완료하지 못했어요. 보존된 복구 자료가 필요합니다.';
      } else {
        _status = TarotBackupRestoreActionStatus.failed;
        _message = result.status == TarotRestoreOperationStatus.failedRolledBack
            ? '복원하지 못해 기존 데이터로 되돌렸어요.'
            : '백업에서 복원하지 못했어요.';
      }
    } on Object catch (error) {
      _fail('백업에서 복원하지 못했어요.', _errorCode(error));
    }
    _pendingCandidate = null;
    notifyListeners();
  }

  void clearResult() {
    if (isBusy) return;
    _reset();
    notifyListeners();
  }

  void _begin(
    TarotBackupRestoreActionStatus status, {
    bool keepCandidate = false,
  }) {
    _status = status;
    if (!keepCandidate) _pendingCandidate = null;
    _message = null;
    _outputPath = null;
    _evidencePath = null;
    _failureCode = null;
    notifyListeners();
  }

  void _fail(String message, String code) {
    _status = TarotBackupRestoreActionStatus.failed;
    _pendingCandidate = null;
    _message = message;
    _failureCode = code;
  }

  void _reset() {
    _status = TarotBackupRestoreActionStatus.idle;
    _pendingCandidate = null;
    _message = null;
    _outputPath = null;
    _evidencePath = null;
    _failureCode = null;
  }
}

Future<String?> _selectRynBackupDirectory() async {
  if (!Platform.isWindows) {
    throw UnsupportedError('restore directory selection requires Windows');
  }
  const script = r'''
$dialog = New-Object -ComObject Shell.Application
$folder = $dialog.BrowseForFolder(0, '복원할 .rynbackup 폴더를 선택하세요.', 0, 0)
if ($null -ne $folder) { [Console]::Out.Write($folder.Self.Path) }
''';
  final result = await Process.run('powershell.exe', <String>[
    '-NoProfile',
    '-STA',
    '-Command',
    script,
  ]);
  if (result.exitCode != 0) {
    throw StateError('restore directory selector failed');
  }
  final selected = (result.stdout as String).trim();
  return selected.isEmpty ? null : selected;
}

String _syntheticBackupRoot(RynResolvedDatabasePath runtime) {
  var root = runtime.profileRootPath;
  for (var index = 0; index < 5; index++) {
    root = p.dirname(root);
  }
  _requireUnderSystemTemp(root);
  return p.join(root, 'backup_output');
}

String _errorCode(Object error) => switch (error) {
  TarotBackupCoordinatorException value => value.code,
  TarotRestoreCandidateValidationException value => value.code,
  _ => error.runtimeType.toString(),
};

String _operationId() {
  final random = Random.secure();
  return List<int>.generate(
    4,
    (_) => random.nextInt(256),
  ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
}

void _requireUnderSystemTemp(String value) {
  final candidate = p.normalize(File(value).absolute.path);
  final root = p.normalize(Directory.systemTemp.absolute.path);
  final safe = candidate == root || p.isWithin(root, candidate);
  if (!safe) throw StateError('synthetic path required');
}
