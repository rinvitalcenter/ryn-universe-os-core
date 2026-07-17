import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../../../../core/backup_recovery/sha256_digest_service.dart';
import '../domain/tarot_backup_manifest.dart';
import 'tarot_backup_database_inspector.dart';
import 'tarot_backup_manifest_codec.dart';
import 'tarot_backup_path_contract.dart';

typedef TarotSnapshotWriter =
    Future<TarotDatabaseEvidence> Function(File payloadFile);
typedef TarotManifestFactory =
    TarotBackupManifest Function({
      required TarotDatabaseEvidence evidence,
      required String payloadSha256,
      required int payloadSizeBytes,
    });
typedef TarotPackageDirectoryHook = Future<void> Function(Directory directory);
typedef TarotPackageFileHook = Future<void> Function(File file);
typedef TarotPackageHook = Future<void> Function();
typedef TarotPackageDirectoryDelete =
    Future<void> Function(Directory directory);

final class TarotBackupPackageStore {
  const TarotBackupPackageStore({
    this.digestService = const DartSha256DigestService(),
    this.manifestCodec = const TarotBackupManifestCodec(),
    this.databaseInspector = const TarotBackupDatabaseInspector(),
    this.beforePayloadHash,
    this.beforeManifestHash,
    this.beforePartialReadback,
    this.afterFinalRename,
    this.deleteDirectory,
  });

  static const int maximumChecksumBytes = 8 * 1024;
  static const int maximumPayloadBytes = 512 * 1024 * 1024;

  final Sha256DigestService digestService;
  final TarotBackupManifestCodec manifestCodec;
  final TarotBackupDatabaseInspector databaseInspector;
  final TarotPackageFileHook? beforePayloadHash;
  final TarotPackageHook? beforeManifestHash;
  final TarotPackageDirectoryHook? beforePartialReadback;
  final TarotPackageDirectoryHook? afterFinalRename;
  final TarotPackageDirectoryDelete? deleteDirectory;

  Future<VerifiedTarotBackupPackage> createVerifiedPackage({
    required ResolvedBackupRecoveryPaths paths,
    required TarotBackupPackagePaths packagePaths,
    required TarotSnapshotWriter snapshotWriter,
    required TarotManifestFactory manifestFactory,
  }) async {
    var renamedToFinal = false;
    var validated = false;
    late ValidatedTarotBackupPackagePaths validatedPaths;
    try {
      validatedPaths = await paths.validatePackagePaths(packagePaths);
      validated = true;
      paths.requireNoValidatedCollision(validatedPaths);
      await paths.requireSafeAncestry(validatedPaths.partialDirectory.path);
      await validatedPaths.partialDirectory.create();
      await paths.requireSafeAncestry(validatedPaths.partialDirectory.path);

      final dataDirectory = Directory(
        _join(validatedPaths.partialDirectory.path, 'data'),
      );
      final checksumDirectory = Directory(
        _join(validatedPaths.partialDirectory.path, 'checksums'),
      );
      await dataDirectory.create();
      await checksumDirectory.create();
      await paths.requireSafeAncestry(dataDirectory.path);
      await paths.requireSafeAncestry(checksumDirectory.path);
      final payload = File(
        _join(
          validatedPaths.partialDirectory.path,
          TarotBackupManifest.databasePayloadFilename,
        ),
      );
      await paths.requireSafeAncestry(payload.path);
      final evidence = await snapshotWriter(payload);
      await beforePayloadHash?.call(payload);
      await _requireExpectedRegularFile(payload, paths);
      final payloadSize = await payload.length();
      if (payloadSize <= 0 || payloadSize > maximumPayloadBytes) {
        throw const TarotBackupPackageException('payload_size_invalid');
      }
      await _requireExpectedRegularFile(payload, paths);
      final payloadHash = await digestService.digestFile(payload);
      final manifest = manifestFactory(
        evidence: evidence,
        payloadSha256: payloadHash,
        payloadSizeBytes: payloadSize,
      );
      final manifestBytes = manifestCodec.encode(manifest);
      final manifestFile = File(
        _join(validatedPaths.partialDirectory.path, 'manifest.json'),
      );
      await paths.requireSafeAncestry(manifestFile.path);
      await _writeFlushed(manifestFile, manifestBytes);
      await beforeManifestHash?.call();
      await _requireExpectedRegularFile(
        manifestFile,
        paths,
        expectedPath: _join(
          validatedPaths.partialDirectory.path,
          'manifest.json',
        ),
      );
      final manifestHash = await digestService.digestFile(manifestFile);
      final checksumBytes = Uint8List.fromList(
        utf8.encode(
          '$manifestHash  manifest.json\n'
          '$payloadHash  ${TarotBackupManifest.databasePayloadFilename}',
        ),
      );
      final checksumFile = File(
        _join(
          validatedPaths.partialDirectory.path,
          TarotBackupManifest.checksumFilename,
        ),
      );
      await paths.requireSafeAncestry(checksumFile.path);
      await _writeFlushed(checksumFile, checksumBytes);

      await beforePartialReadback?.call(validatedPaths.partialDirectory);
      validatedPaths = await paths.validatePackagePaths(
        TarotBackupPackagePaths(
          finalDirectory: validatedPaths.finalDirectory,
          partialDirectory: validatedPaths.partialDirectory,
        ),
      );
      await _verifyPackage(validatedPaths.partialDirectory, paths);
      validatedPaths = await paths.validatePackagePaths(
        TarotBackupPackagePaths(
          finalDirectory: validatedPaths.finalDirectory,
          partialDirectory: validatedPaths.partialDirectory,
        ),
      );
      if (await validatedPaths.finalDirectory.exists()) {
        throw const TarotBackupPackageException('final_collision');
      }
      await validatedPaths.partialDirectory.rename(
        validatedPaths.finalDirectory.path,
      );
      renamedToFinal = true;
      await paths.requireSafeAncestry(validatedPaths.finalDirectory.path);
      await afterFinalRename?.call(validatedPaths.finalDirectory);
      await paths.requireSafeAncestry(validatedPaths.finalDirectory.path);
      final finalManifest = await _verifyPackage(
        validatedPaths.finalDirectory,
        paths,
      );
      return VerifiedTarotBackupPackage(
        finalDirectory: validatedPaths.finalDirectory,
        manifest: finalManifest,
        finalReadbackVerified: true,
      );
    } on TarotBackupPackageException {
      if (validated) {
        await _cleanupFailedArtifact(validatedPaths, paths, renamedToFinal);
      }
      rethrow;
    } on Object {
      if (validated) {
        await _cleanupFailedArtifact(validatedPaths, paths, renamedToFinal);
      }
      throw const TarotBackupPackageException('package_creation_failed');
    }
  }

  Future<TarotBackupManifest> _verifyPackage(
    Directory directory,
    ResolvedBackupRecoveryPaths paths,
  ) async {
    await paths.requireSafeAncestry(directory.path);
    final dataDirectory = Directory(_join(directory.path, 'data'));
    final checksumsDirectory = Directory(_join(directory.path, 'checksums'));
    final manifestFile = File(_join(directory.path, 'manifest.json'));
    final payloadFile = File(
      _join(directory.path, TarotBackupManifest.databasePayloadFilename),
    );
    final checksumFile = File(
      _join(directory.path, TarotBackupManifest.checksumFilename),
    );
    for (final nestedPath in <String>[
      dataDirectory.path,
      checksumsDirectory.path,
      manifestFile.path,
      payloadFile.path,
      checksumFile.path,
    ]) {
      await paths.requireSafeAncestry(nestedPath);
    }
    final top = directory.listSync(followLinks: false);
    if (top.length != 3) {
      throw const TarotBackupPackageException('unexpected_package_structure');
    }
    final expectedTop = <String, FileSystemEntityType>{
      'manifest.json': FileSystemEntityType.file,
      'data': FileSystemEntityType.directory,
      'checksums': FileSystemEntityType.directory,
    };
    for (final entity in top) {
      final name = _basename(entity.path);
      final expected = expectedTop[name];
      final actual = FileSystemEntity.typeSync(entity.path, followLinks: false);
      if (expected == null || actual != expected) {
        throw const TarotBackupPackageException('unexpected_package_structure');
      }
    }
    if (!_hasExactRegularFiles(dataDirectory, <String>{
          'ryn_universe_os_core_snapshot.sqlite',
        }) ||
        !_hasExactRegularFiles(checksumsDirectory, <String>{'sha256.txt'})) {
      throw const TarotBackupPackageException('unexpected_package_structure');
    }

    await _requireExpectedRegularFile(manifestFile, paths);
    final manifestSize = await manifestFile.length();
    await _requireExpectedRegularFile(payloadFile, paths);
    final payloadSize = await payloadFile.length();
    await _requireExpectedRegularFile(checksumFile, paths);
    final checksumSize = await checksumFile.length();
    if (manifestSize > TarotBackupManifestCodec.maximumBytes ||
        checksumSize > maximumChecksumBytes ||
        payloadSize <= 0 ||
        payloadSize > maximumPayloadBytes) {
      throw const TarotBackupPackageException('component_size_invalid');
    }
    await _requireExpectedRegularFile(manifestFile, paths);
    final manifestBytes = await manifestFile.readAsBytes();
    await _requireExpectedRegularFile(checksumFile, paths);
    final checksumBytes = await checksumFile.readAsBytes();
    final manifest = manifestCodec.decode(manifestBytes);
    final checksum = _parseChecksum(checksumBytes);
    await _requireExpectedRegularFile(manifestFile, paths);
    final actualManifestHash = await digestService.digestFile(manifestFile);
    await _requireExpectedRegularFile(payloadFile, paths);
    final actualPayloadHash = await digestService.digestFile(payloadFile);
    if (checksum.manifestHash != actualManifestHash ||
        checksum.payloadHash != actualPayloadHash ||
        manifest.databasePayloadSha256 != actualPayloadHash ||
        manifest.databasePayloadSizeBytes != payloadSize) {
      throw const TarotBackupPackageException('checksum_mismatch');
    }
    await _requireExpectedRegularFile(payloadFile, paths);
    final evidence = databaseInspector.inspectVerified(payloadFile.path);
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
      throw const TarotBackupPackageException('manifest_evidence_mismatch');
    }
    return manifest;
  }

  Future<void> _cleanupFailedArtifact(
    ValidatedTarotBackupPackagePaths packagePaths,
    ResolvedBackupRecoveryPaths paths,
    bool renamedToFinal,
  ) async {
    final directory = renamedToFinal
        ? packagePaths.finalDirectory
        : packagePaths.partialDirectory;
    if (!await directory.exists()) return;
    try {
      await _requireSafeTree(directory, paths);
      if (deleteDirectory != null) {
        await deleteDirectory!(directory);
      } else {
        await directory.delete(recursive: true);
      }
      return;
    } on Object {
      final quarantine = Directory(
        '${directory.path}.quarantine-${DateTime.now().microsecondsSinceEpoch}',
      );
      try {
        await _requireSafeTree(directory, paths);
        await paths.requireSafeBackupDirectChild(quarantine.path);
        await directory.rename(quarantine.path);
      } on Object {
        // Failure is still returned; the incomplete artifact is never success.
      }
    }
  }

  Future<void> _requireExpectedRegularFile(
    File file,
    ResolvedBackupRecoveryPaths paths, {
    String? expectedPath,
  }) async {
    if (expectedPath != null && !_sameAbsolutePath(file.path, expectedPath)) {
      throw const TarotBackupPackageException('unexpected_component_path');
    }
    await paths.requireSafeAncestry(file.path);
    if (FileSystemEntity.typeSync(file.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw const TarotBackupPackageException('payload_not_regular_file');
    }
  }

  Future<void> _requireSafeTree(
    Directory root,
    ResolvedBackupRecoveryPaths paths,
  ) async {
    await paths.requireSafeBackupDirectChild(root.path);
    if (FileSystemEntity.typeSync(root.path, followLinks: false) !=
        FileSystemEntityType.directory) {
      throw const TarotBackupPackageException('unsafe_cleanup_tree');
    }
    final pending = <Directory>[root];
    while (pending.isNotEmpty) {
      final directory = pending.removeLast();
      for (final entity in directory.listSync(followLinks: false)) {
        await paths.requireSafeAncestry(entity.path);
        final type = FileSystemEntity.typeSync(entity.path, followLinks: false);
        if (type == FileSystemEntityType.link) {
          throw const TarotBackupPackageException('unsafe_cleanup_tree');
        }
        if (type == FileSystemEntityType.directory) {
          pending.add(Directory(entity.path));
        } else if (type != FileSystemEntityType.file) {
          throw const TarotBackupPackageException('unsafe_cleanup_tree');
        }
      }
    }
  }
}

final class VerifiedTarotBackupPackage {
  const VerifiedTarotBackupPackage({
    required this.finalDirectory,
    required this.manifest,
    required this.finalReadbackVerified,
  });

  final Directory finalDirectory;
  final TarotBackupManifest manifest;
  final bool finalReadbackVerified;
}

final class TarotBackupPackageException implements Exception {
  const TarotBackupPackageException(this.code);
  final String code;

  @override
  String toString() => 'TarotBackupPackageException($code)';
}

final class _ChecksumEvidence {
  const _ChecksumEvidence({
    required this.manifestHash,
    required this.payloadHash,
  });
  final String manifestHash;
  final String payloadHash;
}

_ChecksumEvidence _parseChecksum(Uint8List bytes) {
  late final String text;
  try {
    text = utf8.decode(bytes, allowMalformed: false);
  } on FormatException {
    throw const TarotBackupPackageException('checksum_invalid');
  }
  final match = RegExp(
    r'^([0-9a-f]{64})  manifest\.json\n'
    r'([0-9a-f]{64})  data/ryn_universe_os_core_snapshot\.sqlite$',
  ).firstMatch(text);
  if (match == null) {
    throw const TarotBackupPackageException('checksum_invalid');
  }
  return _ChecksumEvidence(
    manifestHash: match.group(1)!,
    payloadHash: match.group(2)!,
  );
}

Future<void> _writeFlushed(File file, List<int> bytes) async {
  final handle = await file.open(mode: FileMode.write);
  try {
    await handle.writeFrom(bytes);
    await handle.flush();
  } finally {
    await handle.close();
  }
}

bool _hasExactRegularFiles(Directory directory, Set<String> names) {
  final entries = directory.listSync(followLinks: false);
  if (entries.length != names.length) return false;
  for (final entity in entries) {
    if (FileSystemEntity.typeSync(entity.path, followLinks: false) !=
            FileSystemEntityType.file ||
        !names.contains(_basename(entity.path))) {
      return false;
    }
  }
  return true;
}

String _basename(String path) => path.replaceAll('\\', '/').split('/').last;

String _join(String root, String relative) =>
    '${root.replaceFirst(RegExp(r'[\\/]+$'), '')}${Platform.pathSeparator}'
    '${relative.replaceAll('/', Platform.pathSeparator)}';

bool _sameMap<K, V>(Map<K, V> left, Map<K, V> right) {
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}

bool _sameAbsolutePath(String left, String right) {
  String canonical(String value) => p
      .normalize(File(value).absolute.path)
      .replaceAll('/', r'\')
      .toLowerCase();
  return canonical(left) == canonical(right);
}
