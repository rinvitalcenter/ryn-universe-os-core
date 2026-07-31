import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../tarot/backup_recovery/domain/tarot_backup_manifest.dart';

typedef QigongMarkerFileRename =
    Future<File> Function(File source, String targetPath);

enum QigongCompleteRestorePhase {
  prepared,
  candidateStaged,
  runtimeClosed,
  rollbackCaptured,
  databaseReplaced,
  mediaReplaced,
  databaseReopened,
  validated,
  completed,
  rollbackInProgress,
  fatalPreserved,
}

final class QigongCompleteRestoreOperationMarker {
  const QigongCompleteRestoreOperationMarker({
    required this.operationId,
    required this.phase,
    required this.startedAtUtc,
    required this.updatedAtUtc,
    required this.candidatePackageIdentitySha256,
    required this.stagedDirectoryName,
    required this.rollbackDirectoryName,
    required this.sourceSchemaVersion,
    required this.expectedTargetSchemaVersion,
    required this.lastCompletedStep,
    required this.originalMediaDirectoryPresent,
  });

  static const String operationTypeValue = 'qigongCompleteRestoreV1';

  final String operationId;
  String get operationType => operationTypeValue;
  final QigongCompleteRestorePhase phase;
  final DateTime startedAtUtc;
  final DateTime updatedAtUtc;
  final String candidatePackageIdentitySha256;
  final String stagedDirectoryName;
  final String rollbackDirectoryName;
  final int sourceSchemaVersion;
  final int expectedTargetSchemaVersion;
  final String lastCompletedStep;
  final bool originalMediaDirectoryPresent;

  QigongCompleteRestoreOperationMarker copyWith({
    required QigongCompleteRestorePhase phase,
    required DateTime updatedAtUtc,
  }) => QigongCompleteRestoreOperationMarker(
    operationId: operationId,
    phase: phase,
    startedAtUtc: startedAtUtc,
    updatedAtUtc: updatedAtUtc,
    candidatePackageIdentitySha256: candidatePackageIdentitySha256,
    stagedDirectoryName: stagedDirectoryName,
    rollbackDirectoryName: rollbackDirectoryName,
    sourceSchemaVersion: sourceSchemaVersion,
    expectedTargetSchemaVersion: expectedTargetSchemaVersion,
    lastCompletedStep: phase.name,
    originalMediaDirectoryPresent: originalMediaDirectoryPresent,
  );
}

final class QigongCompleteRestoreOperationMarkerStore {
  const QigongCompleteRestoreOperationMarkerStore({this.renameFile});

  static const String filename = 'qigong-complete-restore-operation.json';
  static const String _nextSuffix = '.next';
  static const String _previousSuffix = '.previous';
  static final RegExp _operationId = RegExp(r'^[0-9a-f]{8}$');
  static final RegExp _sha256 = RegExp(r'^[0-9a-f]{64}$');
  static final RegExp _relativeName = RegExp(
    r'^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$',
  );
  static const List<String> _keys = <String>[
    'operationId',
    'operationType',
    'phase',
    'startedAtUtc',
    'updatedAtUtc',
    'candidatePackageIdentitySha256',
    'stagedDirectoryName',
    'rollbackDirectoryName',
    'sourceSchemaVersion',
    'expectedTargetSchemaVersion',
    'lastCompletedStep',
    'originalMediaDirectoryPresent',
  ];
  final QigongMarkerFileRename? renameFile;

  Future<void> write({
    required Directory operationDirectory,
    required QigongCompleteRestoreOperationMarker marker,
  }) async {
    _validate(marker);
    if (!operationDirectory.existsSync()) {
      await operationDirectory.create(recursive: true);
    }
    final file = File(p.join(operationDirectory.path, filename));
    final next = File('${file.path}$_nextSuffix');
    final previous = File('${file.path}$_previousSuffix');
    await _recoverInterruptedReplacement(
      canonical: file,
      next: next,
      previous: previous,
    );
    if (next.existsSync()) await next.delete();
    await next.writeAsString(encode(marker), encoding: utf8, flush: true);
    if (!file.existsSync()) {
      await _rename(next, file.path);
      return;
    }
    await _rename(file, previous.path);
    try {
      await _rename(next, file.path);
    } on Object {
      if (!file.existsSync() && previous.existsSync()) {
        await _rename(previous, file.path);
      }
      rethrow;
    }
    if (previous.existsSync()) await previous.delete();
  }

  Future<QigongCompleteRestoreOperationMarker> read({
    required Directory operationDirectory,
  }) async {
    final file = File(p.join(operationDirectory.path, filename));
    final previous = File('${file.path}$_previousSuffix');
    final source = file.existsSync() ? file : previous;
    if (!source.existsSync()) {
      throw const FormatException('qigong_restore_marker_missing');
    }
    try {
      return await _readCanonical(source);
    } on FormatException {
      if (source.path != previous.path && previous.existsSync()) {
        return _readCanonical(previous);
      }
      rethrow;
    }
  }

  Future<QigongCompleteRestoreOperationMarker> _readCanonical(File file) async {
    final text = await file.readAsString(encoding: utf8);
    final marker = decode(text);
    if (encode(marker) != text) {
      throw const FormatException('qigong_restore_marker_not_canonical');
    }
    return marker;
  }

  Future<void> _recoverInterruptedReplacement({
    required File canonical,
    required File next,
    required File previous,
  }) async {
    if (!canonical.existsSync() && previous.existsSync()) {
      await _rename(previous, canonical.path);
    }
    if (canonical.existsSync() && previous.existsSync()) {
      await previous.delete();
    }
    if (next.existsSync()) await next.delete();
  }

  Future<File> _rename(File source, String targetPath) =>
      renameFile?.call(source, targetPath) ?? source.rename(targetPath);

  String encode(QigongCompleteRestoreOperationMarker marker) {
    _validate(marker);
    return jsonEncode(<String, Object?>{
      'operationId': marker.operationId,
      'operationType': marker.operationType,
      'phase': marker.phase.name,
      'startedAtUtc': marker.startedAtUtc.toIso8601String(),
      'updatedAtUtc': marker.updatedAtUtc.toIso8601String(),
      'candidatePackageIdentitySha256': marker.candidatePackageIdentitySha256,
      'stagedDirectoryName': marker.stagedDirectoryName,
      'rollbackDirectoryName': marker.rollbackDirectoryName,
      'sourceSchemaVersion': marker.sourceSchemaVersion,
      'expectedTargetSchemaVersion': marker.expectedTargetSchemaVersion,
      'lastCompletedStep': marker.lastCompletedStep,
      'originalMediaDirectoryPresent': marker.originalMediaDirectoryPresent,
    });
  }

  QigongCompleteRestoreOperationMarker decode(String text) {
    late final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const FormatException('qigong_restore_marker_invalid_json');
    }
    if (decoded is! Map<String, Object?> ||
        !_sameStrings(decoded.keys.toList(), _keys)) {
      throw const FormatException('qigong_restore_marker_invalid_contract');
    }
    final operationType = decoded['operationType'];
    final phaseName = decoded['phase'];
    final phase = phaseName is String
        ? QigongCompleteRestorePhase.values
              .where((value) => value.name == phaseName)
              .firstOrNull
        : null;
    final startedAt = _timestamp(decoded['startedAtUtc']);
    final updatedAt = _timestamp(decoded['updatedAtUtc']);
    final marker = QigongCompleteRestoreOperationMarker(
      operationId: decoded['operationId'] is String
          ? decoded['operationId']! as String
          : '',
      phase: phase ?? QigongCompleteRestorePhase.fatalPreserved,
      startedAtUtc: startedAt,
      updatedAtUtc: updatedAt,
      candidatePackageIdentitySha256:
          decoded['candidatePackageIdentitySha256'] is String
          ? decoded['candidatePackageIdentitySha256']! as String
          : '',
      stagedDirectoryName: decoded['stagedDirectoryName'] is String
          ? decoded['stagedDirectoryName']! as String
          : '',
      rollbackDirectoryName: decoded['rollbackDirectoryName'] is String
          ? decoded['rollbackDirectoryName']! as String
          : '',
      sourceSchemaVersion: decoded['sourceSchemaVersion'] is int
          ? decoded['sourceSchemaVersion']! as int
          : -1,
      expectedTargetSchemaVersion: decoded['expectedTargetSchemaVersion'] is int
          ? decoded['expectedTargetSchemaVersion']! as int
          : -1,
      lastCompletedStep: decoded['lastCompletedStep'] is String
          ? decoded['lastCompletedStep']! as String
          : '',
      originalMediaDirectoryPresent:
          decoded['originalMediaDirectoryPresent'] is bool
          ? decoded['originalMediaDirectoryPresent']! as bool
          : false,
    );
    if (operationType !=
            QigongCompleteRestoreOperationMarker.operationTypeValue ||
        phase == null) {
      throw const FormatException('qigong_restore_marker_invalid_contract');
    }
    _validate(marker);
    return marker;
  }

  static DateTime _timestamp(Object? source) {
    if (source is! String || !source.endsWith('Z')) {
      throw const FormatException('qigong_restore_marker_invalid_timestamp');
    }
    final value = DateTime.tryParse(source);
    if (value == null || !value.isUtc || value.toIso8601String() != source) {
      throw const FormatException('qigong_restore_marker_invalid_timestamp');
    }
    return value;
  }

  static void _validate(QigongCompleteRestoreOperationMarker marker) {
    if (!_operationId.hasMatch(marker.operationId) ||
        !_sha256.hasMatch(marker.candidatePackageIdentitySha256) ||
        !_safeRelativeName(marker.stagedDirectoryName) ||
        !_safeRelativeName(marker.rollbackDirectoryName) ||
        !marker.startedAtUtc.isUtc ||
        !marker.updatedAtUtc.isUtc ||
        marker.updatedAtUtc.isBefore(marker.startedAtUtc) ||
        !const <int>{
          TarotBackupManifest.schemaVersionV10,
          TarotBackupManifest.schemaVersion,
        }.contains(marker.sourceSchemaVersion) ||
        !const <int>{
          TarotBackupManifest.schemaVersionV10,
          TarotBackupManifest.schemaVersion,
        }.contains(marker.expectedTargetSchemaVersion) ||
        marker.sourceSchemaVersion > marker.expectedTargetSchemaVersion ||
        marker.lastCompletedStep != marker.phase.name) {
      throw const FormatException('qigong_restore_marker_invalid_contract');
    }
  }

  static bool _safeRelativeName(String value) =>
      _relativeName.hasMatch(value) &&
      value != '.' &&
      value != '..' &&
      !value.contains('/') &&
      !value.contains(r'\');
}

bool _sameStrings(List<String> left, List<String> right) =>
    left.length == right.length &&
    Iterable<int>.generate(
      left.length,
    ).every((index) => left[index] == right[index]);
