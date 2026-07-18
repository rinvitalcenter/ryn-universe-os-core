import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../../../../core/backup_recovery/sha256_digest_service.dart';
import '../../../../../core/backup_recovery/windows_reparse_point_inspector.dart';
import '../domain/tarot_backup_manifest.dart';
import '../domain/tarot_restore_candidate.dart';
import 'tarot_backup_database_inspector.dart';
import 'tarot_backup_manifest_codec.dart';
import 'tarot_backup_package_store.dart';
import 'tarot_backup_path_contract.dart';

final class TarotRestoreCandidateValidator {
  TarotRestoreCandidateValidator({
    this.digestService = const DartSha256DigestService(),
    this.manifestCodec = const TarotBackupManifestCodec(),
    this.databaseInspector = const TarotBackupDatabaseInspector(),
    TarotBackupPathInspection? inspectPath,
    this.protectedRootPaths = const <String>[],
  }) : _inspectPath = inspectPath ?? _defaultInspection;

  final Sha256DigestService digestService;
  final TarotBackupManifestCodec manifestCodec;
  final TarotBackupDatabaseInspector databaseInspector;
  final List<String> protectedRootPaths;
  final TarotBackupPathInspection _inspectPath;

  static final RegExp _packageName = RegExp(
    r'^RynTarotBackup_([0-9]{8}T[0-9]{6}Z)_([0-9a-f]{8})\.rynbackup$',
  );

  Future<TarotRestoreCandidate> validate(String candidatePath) async {
    final packagePath = _absolute(candidatePath);
    _rejectProtectedPath(packagePath);

    final nameMatch = _packageName.firstMatch(p.basename(packagePath));
    if (nameMatch == null ||
        FileSystemEntity.typeSync(packagePath, followLinks: false) !=
            FileSystemEntityType.directory) {
      throw const TarotRestoreCandidateValidationException(
        'candidate_root_invalid',
      );
    }
    await _requireSafe(packagePath);

    final dataPath = _join(packagePath, 'data');
    final checksumsPath = _join(packagePath, 'checksums');
    final manifestPath = _join(packagePath, 'manifest.json');
    final snapshotPath = _join(
      packagePath,
      TarotBackupManifest.databasePayloadFilename,
    );
    final checksumPath = _join(
      packagePath,
      TarotBackupManifest.checksumFilename,
    );

    for (final path in <String>[
      dataPath,
      checksumsPath,
      manifestPath,
      snapshotPath,
      checksumPath,
    ]) {
      if (FileSystemEntity.typeSync(path, followLinks: false) ==
          FileSystemEntityType.notFound) {
        throw const TarotRestoreCandidateValidationException(
          'required_component_missing',
        );
      }
    }
    await _requireExactStructure(
      packagePath: packagePath,
      dataPath: dataPath,
      checksumsPath: checksumsPath,
      manifestPath: manifestPath,
      snapshotPath: snapshotPath,
      checksumPath: checksumPath,
    );

    final manifestFile = File(manifestPath);
    final snapshotFile = File(snapshotPath);
    final checksumFile = File(checksumPath);
    final manifestSize = await manifestFile.length();
    final snapshotSize = await snapshotFile.length();
    final checksumSize = await checksumFile.length();
    if (manifestSize > TarotBackupManifestCodec.maximumBytes ||
        checksumSize > TarotBackupPackageStore.maximumChecksumBytes ||
        snapshotSize <= 0 ||
        snapshotSize > TarotBackupPackageStore.maximumPayloadBytes) {
      throw const TarotRestoreCandidateValidationException(
        'component_size_invalid',
      );
    }

    await _requireSafeRegularFile(manifestPath);
    late final TarotBackupManifest manifest;
    try {
      manifest = manifestCodec.decode(await manifestFile.readAsBytes());
    } on FormatException {
      throw const TarotRestoreCandidateValidationException('manifest_invalid');
    }
    final packageTimestamp = nameMatch.group(1)!;
    if (_packageTimestamp(manifest.createdAtUtc) != packageTimestamp) {
      throw const TarotRestoreCandidateValidationException(
        'package_identity_mismatch',
      );
    }

    await _requireSafeRegularFile(checksumPath);
    final checksum = _parseChecksum(await checksumFile.readAsBytes());
    await _requireSafeRegularFile(manifestPath);
    final actualManifestHash = await digestService.digestFile(manifestFile);
    await _requireSafeRegularFile(snapshotPath);
    final actualSnapshotHash = await digestService.digestFile(snapshotFile);
    await _requireSafeRegularFile(snapshotPath);
    final finalSnapshotSize = await snapshotFile.length();
    if (checksum.manifestHash != actualManifestHash ||
        checksum.snapshotHash != manifest.databasePayloadSha256 ||
        checksum.snapshotHash != actualSnapshotHash ||
        manifest.databasePayloadSizeBytes != finalSnapshotSize ||
        snapshotSize != finalSnapshotSize) {
      throw const TarotRestoreCandidateValidationException('checksum_mismatch');
    }

    await _requireSafeRegularFile(snapshotPath);
    late final TarotDatabaseEvidence evidence;
    try {
      evidence = databaseInspector.inspectVerified(
        snapshotPath,
        policy: TarotDatabaseInspectionPolicy.immutableReadOnlyFrozenTarget,
        requireAcceptableSidecars: true,
      );
    } on TarotBackupInspectionException {
      throw const TarotRestoreCandidateValidationException('snapshot_invalid');
    }
    if (!_sameMap(evidence.tableRowCounts, manifest.tableRowCounts) ||
        evidence.distinctReadingIdCount != manifest.readingIdCount ||
        evidence.placementCount != manifest.placementCount ||
        evidence.interpretationCount != manifest.interpretationCount ||
        evidence.runtimeStateRowCount != manifest.runtimeStateRowCount ||
        evidence.activeHomeReadingIdPresent !=
            manifest.activeHomeReadingIdPresent ||
        !_sameMap(
          evidence.lifecycleStateCounts,
          manifest.lifecycleStateCounts,
        ) ||
        evidence.freelistCount != 0 ||
        evidence.hasUnexpectedNonEmptySidecar) {
      throw const TarotRestoreCandidateValidationException('snapshot_invalid');
    }

    return TarotRestoreCandidate(
      packagePath: packagePath,
      snapshotPath: _absolute(snapshotPath),
      createdAtUtc: manifest.createdAtUtc,
      operationId: nameMatch.group(2)!,
      backupFormatVersion: TarotBackupManifest.backupFormatVersion,
      schemaVersion: evidence.schemaVersion,
      snapshotSha256: actualSnapshotHash,
      snapshotSizeBytes: finalSnapshotSize,
    );
  }

  void _rejectProtectedPath(String candidate) {
    for (final protected in protectedRootPaths) {
      final normalized = _absolute(protected);
      if (_sameOrWithin(candidate, normalized) ||
          _sameOrWithin(normalized, candidate)) {
        throw const TarotRestoreCandidateValidationException('protected_path');
      }
    }
  }

  Future<void> _requireExactStructure({
    required String packagePath,
    required String dataPath,
    required String checksumsPath,
    required String manifestPath,
    required String snapshotPath,
    required String checksumPath,
  }) async {
    for (final directory in <String>[dataPath, checksumsPath]) {
      if (FileSystemEntity.typeSync(directory, followLinks: false) !=
          FileSystemEntityType.directory) {
        throw const TarotRestoreCandidateValidationException(
          'unexpected_package_structure',
        );
      }
      await _requireSafe(directory);
    }
    for (final file in <String>[manifestPath, snapshotPath, checksumPath]) {
      await _requireSafeRegularFile(file);
    }

    final expected = <String, FileSystemEntityType>{
      _absolute(manifestPath): FileSystemEntityType.file,
      _absolute(dataPath): FileSystemEntityType.directory,
      _absolute(checksumsPath): FileSystemEntityType.directory,
      _absolute(snapshotPath): FileSystemEntityType.file,
      _absolute(checksumPath): FileSystemEntityType.file,
    };
    final actual = <String, FileSystemEntityType>{};
    final pending = <Directory>[Directory(packagePath)];
    while (pending.isNotEmpty) {
      final directory = pending.removeLast();
      for (final entity in directory.listSync(followLinks: false)) {
        final path = _absolute(entity.path);
        final type = FileSystemEntity.typeSync(path, followLinks: false);
        await _requireSafe(path);
        actual[path] = type;
        if (type == FileSystemEntityType.directory) {
          pending.add(Directory(path));
        }
      }
    }
    if (actual.length != expected.length) {
      throw const TarotRestoreCandidateValidationException(
        'unexpected_package_structure',
      );
    }
    for (final entry in expected.entries) {
      if (actual[entry.key] != entry.value) {
        throw const TarotRestoreCandidateValidationException(
          'unexpected_package_structure',
        );
      }
    }
  }

  Future<void> _requireSafeRegularFile(String path) async {
    if (FileSystemEntity.typeSync(path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw const TarotRestoreCandidateValidationException(
        'unexpected_package_structure',
      );
    }
    await _requireSafe(path);
  }

  Future<void> _requireSafe(String path) async {
    if (!await _inspectPath(path)) {
      throw const TarotRestoreCandidateValidationException('unsafe_path');
    }
  }

  static Future<bool> _defaultInspection(String path) async =>
      const WindowsReparsePointInspector().isSafe(path);
}

final class TarotRestoreCandidateValidationException implements Exception {
  const TarotRestoreCandidateValidationException(this.code);

  final String code;

  @override
  String toString() => 'TarotRestoreCandidateValidationException($code)';
}

final class _ChecksumEvidence {
  const _ChecksumEvidence({
    required this.manifestHash,
    required this.snapshotHash,
  });

  final String manifestHash;
  final String snapshotHash;
}

_ChecksumEvidence _parseChecksum(Uint8List bytes) {
  late final String text;
  try {
    text = utf8.decode(bytes, allowMalformed: false);
  } on FormatException {
    throw const TarotRestoreCandidateValidationException('checksum_invalid');
  }
  final match = RegExp(
    r'^([0-9a-f]{64})  manifest\.json\n'
    r'([0-9a-f]{64})  data/ryn_universe_os_core_snapshot\.sqlite$',
  ).firstMatch(text);
  if (match == null) {
    throw const TarotRestoreCandidateValidationException('checksum_invalid');
  }
  return _ChecksumEvidence(
    manifestHash: match.group(1)!,
    snapshotHash: match.group(2)!,
  );
}

String _packageTimestamp(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}'
    '${value.month.toString().padLeft(2, '0')}'
    '${value.day.toString().padLeft(2, '0')}'
    'T${value.hour.toString().padLeft(2, '0')}'
    '${value.minute.toString().padLeft(2, '0')}'
    '${value.second.toString().padLeft(2, '0')}Z';

String _absolute(String value) => p.normalize(File(value).absolute.path);

String _join(String root, String relative) =>
    p.joinAll(<String>[root, ...relative.split('/')]);

String _normalized(String value) =>
    _absolute(value).replaceAll('/', r'\').toLowerCase();

bool _sameOrWithin(String candidate, String root) {
  final left = _normalized(candidate);
  final right = _normalized(root);
  return left == right || left.startsWith('$right\\');
}

bool _sameMap<K, V>(Map<K, V> left, Map<K, V> right) {
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}
