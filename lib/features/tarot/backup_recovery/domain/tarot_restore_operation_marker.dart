import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../infrastructure/tarot_backup_path_contract.dart';

enum TarotRestoreMarkerStage {
  prepared,
  originalPreserved,
  candidateInstalled,
  replacementVerified,
  rollbackStarted,
  rollbackCompleted,
  fatalPreserved,
}

final class TarotRestoreOperationMarker {
  TarotRestoreOperationMarker({
    required this.operationId,
    required this.stage,
    required this.liveDatabasePath,
    required this.preservedOriginalDirectory,
    required this.candidatePackagePath,
    required this.safetyBackupPackagePath,
    required this.startedAtUtc,
    required this.updatedAtUtc,
  }) {
    validate();
  }

  final String operationId;
  final TarotRestoreMarkerStage stage;
  final String liveDatabasePath;
  final String preservedOriginalDirectory;
  final String candidatePackagePath;
  final String safetyBackupPackagePath;
  final DateTime startedAtUtc;
  final DateTime updatedAtUtc;

  TarotRestoreOperationMarker copyWith({
    required TarotRestoreMarkerStage stage,
    required DateTime updatedAtUtc,
  }) => TarotRestoreOperationMarker(
    operationId: operationId,
    stage: stage,
    liveDatabasePath: liveDatabasePath,
    preservedOriginalDirectory: preservedOriginalDirectory,
    candidatePackagePath: candidatePackagePath,
    safetyBackupPackagePath: safetyBackupPackagePath,
    startedAtUtc: startedAtUtc,
    updatedAtUtc: updatedAtUtc,
  );

  void validate() {
    if (!RegExp(r'^[0-9a-f]{8}$').hasMatch(operationId) ||
        !startedAtUtc.isUtc ||
        !updatedAtUtc.isUtc ||
        updatedAtUtc.isBefore(startedAtUtc) ||
        !_validAbsolutePath(liveDatabasePath) ||
        !_validAbsolutePath(preservedOriginalDirectory) ||
        !_validAbsolutePath(candidatePackagePath) ||
        !_validAbsolutePath(safetyBackupPackagePath)) {
      throw const TarotRestoreOperationMarkerException('marker_invalid');
    }
  }
}

final class TarotRestoreOperationMarkerStore {
  const TarotRestoreOperationMarkerStore();

  static const filename = 'restore-operation.json';
  static const _maxBytes = 8192;
  static const _keys = <String>{
    'operationId',
    'stage',
    'liveDatabasePath',
    'preservedOriginalDirectory',
    'candidatePackagePath',
    'safetyBackupPackagePath',
    'startedAtUtc',
    'updatedAtUtc',
  };

  String encode(TarotRestoreOperationMarker marker) {
    marker.validate();
    return jsonEncode(<String, Object>{
      'operationId': marker.operationId,
      'stage': marker.stage.name,
      'liveDatabasePath': marker.liveDatabasePath,
      'preservedOriginalDirectory': marker.preservedOriginalDirectory,
      'candidatePackagePath': marker.candidatePackagePath,
      'safetyBackupPackagePath': marker.safetyBackupPackagePath,
      'startedAtUtc': marker.startedAtUtc.toIso8601String(),
      'updatedAtUtc': marker.updatedAtUtc.toIso8601String(),
    });
  }

  Future<void> write({
    required Directory operationDirectory,
    required ResolvedBackupRecoveryPaths paths,
    required TarotRestoreOperationMarker marker,
  }) async {
    marker.validate();
    await _requireOperationDirectory(operationDirectory, paths);
    final file = File(p.join(operationDirectory.path, filename));
    await paths.requireSafeAncestry(file.path);
    final type = FileSystemEntity.typeSync(file.path, followLinks: false);
    if (type != FileSystemEntityType.notFound &&
        type != FileSystemEntityType.file) {
      throw const TarotRestoreOperationMarkerException('marker_path_unsafe');
    }
    final bytes = utf8.encode(encode(marker));
    if (bytes.length > _maxBytes) {
      throw const TarotRestoreOperationMarkerException('marker_too_large');
    }
    final handle = await file.open(mode: FileMode.write);
    try {
      await handle.writeFrom(bytes);
      await handle.flush();
    } finally {
      await handle.close();
    }
  }

  Future<TarotRestoreOperationMarker> read({
    required Directory operationDirectory,
    required ResolvedBackupRecoveryPaths paths,
  }) async {
    await _requireOperationDirectory(operationDirectory, paths);
    final file = File(p.join(operationDirectory.path, filename));
    await paths.requireSafeAncestry(file.path);
    if (FileSystemEntity.typeSync(file.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw const TarotRestoreOperationMarkerException('marker_missing');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty || bytes.length > _maxBytes) {
      throw const TarotRestoreOperationMarkerException('marker_size_invalid');
    }
    late final String text;
    late final Object? decoded;
    try {
      text = utf8.decode(bytes, allowMalformed: false);
      decoded = jsonDecode(text);
    } on Object {
      throw const TarotRestoreOperationMarkerException('marker_decode_failed');
    }
    if (decoded is! Map<String, Object?> ||
        decoded.keys.toSet().length != _keys.length ||
        !decoded.keys.toSet().containsAll(_keys)) {
      throw const TarotRestoreOperationMarkerException(
        'marker_contract_invalid',
      );
    }
    late final TarotRestoreMarkerStage stage;
    try {
      stage = TarotRestoreMarkerStage.values.byName(_string(decoded, 'stage'));
    } on Object {
      throw const TarotRestoreOperationMarkerException('marker_stage_unknown');
    }
    late final TarotRestoreOperationMarker marker;
    try {
      marker = TarotRestoreOperationMarker(
        operationId: _string(decoded, 'operationId'),
        stage: stage,
        liveDatabasePath: _string(decoded, 'liveDatabasePath'),
        preservedOriginalDirectory: _string(
          decoded,
          'preservedOriginalDirectory',
        ),
        candidatePackagePath: _string(decoded, 'candidatePackagePath'),
        safetyBackupPackagePath: _string(decoded, 'safetyBackupPackagePath'),
        startedAtUtc: DateTime.parse(_string(decoded, 'startedAtUtc')),
        updatedAtUtc: DateTime.parse(_string(decoded, 'updatedAtUtc')),
      );
    } on Object {
      throw const TarotRestoreOperationMarkerException(
        'marker_contract_invalid',
      );
    }
    if (encode(marker) != text) {
      throw const TarotRestoreOperationMarkerException('marker_noncanonical');
    }
    return marker;
  }

  Future<void> remove({
    required Directory operationDirectory,
    required ResolvedBackupRecoveryPaths paths,
  }) async {
    final file = File(p.join(operationDirectory.path, filename));
    await paths.requireSafeAncestry(file.path);
    if (FileSystemEntity.typeSync(file.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw const TarotRestoreOperationMarkerException('marker_missing');
    }
    await file.delete();
  }
}

final class TarotRestoreOperationMarkerException implements Exception {
  const TarotRestoreOperationMarkerException(this.code);

  final String code;

  @override
  String toString() => 'TarotRestoreOperationMarkerException($code)';
}

Future<void> _requireOperationDirectory(
  Directory directory,
  ResolvedBackupRecoveryPaths paths,
) async {
  await paths.requireSafeAncestry(directory.path);
  if (FileSystemEntity.typeSync(directory.path, followLinks: false) !=
      FileSystemEntityType.directory) {
    throw const TarotRestoreOperationMarkerException(
      'operation_directory_unsafe',
    );
  }
}

String _string(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is! String) {
    throw const TarotRestoreOperationMarkerException('marker_contract_invalid');
  }
  return value;
}

bool _validAbsolutePath(String value) =>
    value.isNotEmpty &&
    p.isAbsolute(value) &&
    !value.contains(RegExp(r'[\x00-\x1f]'));
