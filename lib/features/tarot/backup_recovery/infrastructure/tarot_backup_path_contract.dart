import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../../../core/backup_recovery/windows_reparse_point_inspector.dart';

typedef TarotBackupPathInspection = Future<bool> Function(String path);

final class TarotBackupPathContract {
  TarotBackupPathContract({
    required this.sourceRootPath,
    required this.backupRootPath,
    required this.protectedRootPaths,
    TarotBackupPathInspection? inspectPath,
  }) : _inspectPath = inspectPath ?? _defaultInspection;

  final String sourceRootPath;
  final String backupRootPath;
  final List<String> protectedRootPaths;
  final TarotBackupPathInspection _inspectPath;

  static String standardConceptualBackupRoot(String downloadsPath) =>
      _join(downloadsPath, 'Ryn Universe OS Backups');

  ResolvedBackupRecoveryPaths resolve() {
    final source = _absolute(sourceRootPath);
    final backup = _absolute(backupRootPath);
    final systemTemp = _absolute(Directory.systemTemp.path);
    if (!_strictlyWithin(source, systemTemp) ||
        !_strictlyWithin(backup, systemTemp)) {
      throw const TarotBackupPathException('non_allowlisted_injected_root');
    }
    if (_sameOrWithin(source, backup) || _sameOrWithin(backup, source)) {
      throw const TarotBackupPathException('source_destination_overlap');
    }
    for (final protected in protectedRootPaths) {
      final normalized = _absolute(protected);
      if (_sameOrWithin(backup, normalized) ||
          _sameOrWithin(normalized, backup)) {
        throw const TarotBackupPathException('protected_backup_root');
      }
    }
    return ResolvedBackupRecoveryPaths._(
      sourceRootPath: source,
      backupRootPath: backup,
      inspectPath: _inspectPath,
    );
  }

  static Future<bool> _defaultInspection(String path) async {
    return const WindowsReparsePointInspector().isSafe(path);
  }
}

final class ResolvedBackupRecoveryPaths {
  const ResolvedBackupRecoveryPaths._({
    required this.sourceRootPath,
    required this.backupRootPath,
    required this.inspectPath,
  });

  final String sourceRootPath;
  final String backupRootPath;
  final TarotBackupPathInspection inspectPath;

  void validateSafeRelativePath(String value) {
    if (value.isEmpty ||
        value.startsWith('/') ||
        value.startsWith(r'\') ||
        RegExp(r'^[A-Za-z]:').hasMatch(value) ||
        value.startsWith(r'\\?\') ||
        value.startsWith(r'\\.\') ||
        value.contains(':')) {
      throw const TarotBackupPathException('unsafe_relative_path');
    }
    final components = value.split(RegExp(r'[\\/]'));
    if (components.any((part) => part.isEmpty || part == '.' || part == '..') ||
        components.any((part) => part.toLowerCase().endsWith('.rynbackup'))) {
      throw const TarotBackupPathException('unsafe_relative_path');
    }
  }

  void validateSourceDatabasePath(String path) {
    if (!_strictlyWithin(_absolute(path), sourceRootPath)) {
      throw const TarotBackupPathException('source_outside_allowed_root');
    }
  }

  void validateTargetSnapshotPath(String path) {
    final absolute = _absolute(path);
    if (!_strictlyWithin(absolute, backupRootPath) ||
        _sameOrWithin(absolute, sourceRootPath)) {
      throw const TarotBackupPathException('target_outside_allowed_root');
    }
  }

  TarotBackupPackagePaths packagePaths({
    required DateTime createdAtUtc,
    required String operationId,
  }) {
    if (!createdAtUtc.isUtc ||
        !RegExp(r'^[0-9a-f]{8}$').hasMatch(operationId)) {
      throw const TarotBackupPathException('invalid_package_identity');
    }
    final timestamp =
        '${createdAtUtc.year.toString().padLeft(4, '0')}'
        '${createdAtUtc.month.toString().padLeft(2, '0')}'
        '${createdAtUtc.day.toString().padLeft(2, '0')}'
        'T${createdAtUtc.hour.toString().padLeft(2, '0')}'
        '${createdAtUtc.minute.toString().padLeft(2, '0')}'
        '${createdAtUtc.second.toString().padLeft(2, '0')}Z';
    final finalName = 'RynTarotBackup_${timestamp}_$operationId.rynbackup';
    final partialName = '.$finalName.partial-$operationId';
    return TarotBackupPackagePaths(
      finalDirectory: Directory(_join(backupRootPath, finalName)),
      partialDirectory: Directory(_join(backupRootPath, partialName)),
    );
  }

  void requireNoCollision(TarotBackupPackagePaths paths) {
    if (paths.finalDirectory.existsSync() ||
        paths.partialDirectory.existsSync()) {
      throw const TarotBackupPathException('package_collision');
    }
  }

  void requireNoValidatedCollision(ValidatedTarotBackupPackagePaths paths) {
    if (paths.finalDirectory.existsSync() ||
        paths.partialDirectory.existsSync()) {
      throw const TarotBackupPathException('package_collision');
    }
  }

  Future<ValidatedTarotBackupPackagePaths> validatePackagePaths(
    TarotBackupPackagePaths paths,
  ) async {
    final backup = _absolute(backupRootPath);
    final partial = _absolute(paths.partialDirectory.path);
    final finalPath = _absolute(paths.finalDirectory.path);
    if (!_samePath(_parent(partial), backup) ||
        !_samePath(_parent(finalPath), backup) ||
        _samePath(partial, finalPath) ||
        !_validFinalPackageName(_basename(finalPath)) ||
        !_validPartialPackageName(_basename(partial), _basename(finalPath))) {
      throw const TarotBackupPathException('invalid_package_paths');
    }
    await requireSafeAncestry(backup);
    await requireSafeAncestry(partial);
    await requireSafeAncestry(finalPath);
    return ValidatedTarotBackupPackagePaths._(
      finalDirectory: Directory(finalPath),
      partialDirectory: Directory(partial),
    );
  }

  void validateTargetCleanupPath(String candidate, String target) {
    validateTargetSnapshotPath(target);
    final expected = _absolute(target);
    final actual = _absolute(candidate);
    if (!<String>{
      expected,
      '$expected-wal',
      '$expected-shm',
      '$expected-journal',
    }.any((path) => _samePath(path, actual))) {
      throw const TarotBackupPathException('invalid_cleanup_target');
    }
  }

  Future<void> requireSafeBackupDirectChild(String path) async {
    if (!_samePath(_parent(_absolute(path)), _absolute(backupRootPath))) {
      throw const TarotBackupPathException('not_backup_root_child');
    }
    await requireSafeAncestry(path);
  }

  Future<void> requireSafeAncestry(String path) async {
    final absolute = _absolute(path);
    if (!_sameOrWithin(absolute, backupRootPath) &&
        !_sameOrWithin(absolute, sourceRootPath)) {
      throw const TarotBackupPathException('path_outside_allowed_roots');
    }
    if (!await inspectPath(path)) {
      throw const TarotBackupPathException('unsafe_path_ancestry');
    }
  }
}

final class TarotBackupPackagePaths {
  const TarotBackupPackagePaths({
    required this.finalDirectory,
    required this.partialDirectory,
  });

  final Directory finalDirectory;
  final Directory partialDirectory;
}

final class ValidatedTarotBackupPackagePaths {
  const ValidatedTarotBackupPackagePaths._({
    required this.finalDirectory,
    required this.partialDirectory,
  });

  final Directory finalDirectory;
  final Directory partialDirectory;
}

final class TarotBackupPathException implements Exception {
  const TarotBackupPathException(this.code);
  final String code;

  @override
  String toString() => 'TarotBackupPathException($code)';
}

String _absolute(String path) {
  var absolute = p.normalize(File(path).absolute.path).replaceAll('/', r'\');
  while (absolute.length > 3 && absolute.endsWith(r'\')) {
    absolute = absolute.substring(0, absolute.length - 1);
  }
  return absolute;
}

String _normalize(String path) {
  var normalized = path.replaceAll('/', r'\');
  while (normalized.length > 3 && normalized.endsWith(r'\')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized.toLowerCase();
}

bool _sameOrWithin(String candidate, String root) {
  final left = _normalize(candidate);
  final right = _normalize(root);
  return left == right || left.startsWith('$right\\');
}

bool _strictlyWithin(String candidate, String root) =>
    _normalize(candidate) != _normalize(root) && _sameOrWithin(candidate, root);

bool _samePath(String left, String right) =>
    _normalize(left) == _normalize(right);

String _parent(String path) => p.dirname(path);

String _basename(String path) => p.basename(path);

bool _validFinalPackageName(String name) => RegExp(
  r'^RynTarotBackup_[0-9]{8}T[0-9]{6}Z_[0-9a-f]{8}\.rynbackup$',
).hasMatch(name);

bool _validPartialPackageName(String partial, String finalName) {
  final operationId = finalName.substring(
    finalName.length - '.rynbackup'.length - 8,
    finalName.length - '.rynbackup'.length,
  );
  return partial == '.$finalName.partial-$operationId';
}

String _join(String left, String right) =>
    '${left.replaceFirst(RegExp(r'[\\/]+$'), '')}${Platform.pathSeparator}$right';
