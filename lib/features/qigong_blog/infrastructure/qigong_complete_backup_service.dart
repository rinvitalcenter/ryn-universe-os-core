import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../../../core/backup_recovery/sha256_digest_service.dart';
import '../../tarot/backup_recovery/domain/tarot_backup_manifest.dart';
import '../../tarot/backup_recovery/infrastructure/tarot_backup_database_inspector.dart';
import '../../tarot/backup_recovery/infrastructure/tarot_backup_path_contract.dart';
import '../../tarot/backup_recovery/infrastructure/tarot_sqlite_online_backup_service.dart';

final class QigongBackupEvidence {
  const QigongBackupEvidence({
    required this.schemaVersion,
    required this.mediaCount,
    required this.databaseSha256,
  });

  final int schemaVersion;
  final int mediaCount;
  final String databaseSha256;
}

final class QigongBackupException implements Exception {
  const QigongBackupException(this.code);
  final String code;

  @override
  String toString() => 'QigongBackupException($code)';
}

final class QigongCompleteBackupService {
  QigongCompleteBackupService({
    required this.profileRoot,
    required this.sourceDatabaseFile,
    required this.backupRoot,
    this.digestService = const DartSha256DigestService(),
    this.databaseInspector = const TarotBackupDatabaseInspector(),
    this.onlineBackupService = const TarotSqliteOnlineBackupService(),
  });

  static const _databaseRelativePath =
      'data/ryn_universe_os_core_snapshot.sqlite';
  static const _checksumRelativePath = 'checksums/sha256.txt';
  static const _manifestFilename = 'manifest.json';
  static const _mediaPrefix = 'media/';

  final Directory profileRoot;
  final File sourceDatabaseFile;
  final Directory backupRoot;
  final Sha256DigestService digestService;
  final TarotBackupDatabaseInspector databaseInspector;
  final TarotSqliteOnlineBackupService onlineBackupService;

  Future<Directory> createBackup({
    required DateTime createdAtUtc,
    required String operationId,
  }) async {
    _validateIdentity(createdAtUtc, operationId);
    final paths = _resolvedPaths();
    final stamp = _timestamp(createdAtUtc);
    final finalDirectory = Directory(
      p.join(
        backupRoot.path,
        'RynQigongBackup_${stamp}_$operationId.rynbackup',
      ),
    );
    final partialDirectory = Directory(
      '${finalDirectory.path}.partial-$operationId',
    );
    if (await finalDirectory.exists() || await partialDirectory.exists()) {
      throw const QigongBackupException('package_collision');
    }
    try {
      await partialDirectory.create(recursive: true);
      final snapshot = File(
        p.joinAll([
          partialDirectory.path,
          ...p.posix.split(_databaseRelativePath),
        ]),
      );
      await snapshot.parent.create(recursive: true);
      await onlineBackupService.createSnapshot(
        sourceDatabasePath: sourceDatabaseFile.path,
        targetDatabasePath: snapshot.path,
        paths: paths,
      );
      final databaseHash = await digestService.digestFile(snapshot);
      final mediaEntries = await _databaseMediaEntries(snapshot);
      for (final entry in mediaEntries) {
        final source = _resolveProfileRelative(entry.relativePath);
        if (!await source.exists()) {
          throw const QigongBackupException('managed_media_missing');
        }
        final actualHash = await digestService.digestFile(source);
        if (actualHash != entry.sha256) {
          throw const QigongBackupException('managed_media_hash_mismatch');
        }
        final target = _packageMediaFile(partialDirectory, entry.relativePath);
        await target.parent.create(recursive: true);
        await source.copy(target.path);
        if (await digestService.digestFile(target) != entry.sha256) {
          throw const QigongBackupException('media_copy_hash_mismatch');
        }
      }
      await Directory(
        p.join(partialDirectory.path, 'media'),
      ).create(recursive: true);
      final manifest = _manifest(
        createdAtUtc: createdAtUtc,
        databaseSize: await snapshot.length(),
        databaseHash: databaseHash,
        mediaEntries: mediaEntries,
      );
      await File(
        p.join(partialDirectory.path, _manifestFilename),
      ).writeAsString(jsonEncode(manifest), flush: true);
      final checksumFile = File(
        p.joinAll([
          partialDirectory.path,
          ...p.posix.split(_checksumRelativePath),
        ]),
      );
      await checksumFile.parent.create(recursive: true);
      await checksumFile.writeAsString(
        _checksumText(databaseHash, mediaEntries),
        flush: true,
      );
      await validateBackup(partialDirectory);
      await partialDirectory.rename(finalDirectory.path);
      await validateBackup(finalDirectory);
      return finalDirectory;
    } on QigongBackupException {
      await _deleteIfExists(partialDirectory);
      rethrow;
    } on Object {
      await _deleteIfExists(partialDirectory);
      throw const QigongBackupException('backup_creation_failed');
    }
  }

  Future<QigongBackupEvidence> validateBackup(Directory package) async {
    try {
      if (!await package.exists()) {
        throw const QigongBackupException('package_missing');
      }
      final manifestFile = File(p.join(package.path, _manifestFilename));
      if (!await manifestFile.exists()) {
        throw const QigongBackupException('manifest_missing');
      }
      final raw = await manifestFile.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> || jsonEncode(decoded) != raw) {
        throw const QigongBackupException('manifest_noncanonical');
      }
      final manifest = decoded;
      if (manifest['backupFormatVersion'] != 1 ||
          manifest['applicationIdentity'] !=
              TarotBackupManifest.applicationIdentity ||
          manifest['contentScope'] != 'qigong_complete_document_media_v1' ||
          manifest['schemaVersion'] != TarotBackupManifest.schemaVersion ||
          manifest['databaseRelativePath'] != _databaseRelativePath ||
          manifest['checksumRelativePath'] != _checksumRelativePath) {
        throw const QigongBackupException('manifest_contract_mismatch');
      }
      final snapshot = File(
        p.joinAll([package.path, ...p.posix.split(_databaseRelativePath)]),
      );
      if (!await snapshot.exists()) {
        throw const QigongBackupException('database_payload_missing');
      }
      final expectedDatabaseHash = manifest['databaseSha256'];
      if (expectedDatabaseHash is! String ||
          await digestService.digestFile(snapshot) != expectedDatabaseHash) {
        throw const QigongBackupException('database_hash_mismatch');
      }
      if (manifest['databaseSizeBytes'] != await snapshot.length()) {
        throw const QigongBackupException('database_size_mismatch');
      }
      final evidence = databaseInspector.inspectVerified(
        snapshot.path,
        policy: TarotDatabaseInspectionPolicy.immutableReadOnlyFrozenTarget,
        requireAcceptableSidecars: true,
      );
      final manifestEntries = _manifestEntries(manifest['media']);
      final databaseEntries = await _databaseMediaEntries(snapshot);
      if (!_sameMediaEntries(manifestEntries, databaseEntries)) {
        throw const QigongBackupException('media_manifest_database_mismatch');
      }
      for (final entry in manifestEntries) {
        final file = _packageMediaFile(package, entry.relativePath);
        if (!await file.exists()) {
          throw const QigongBackupException('media_payload_missing');
        }
        if (await file.length() != entry.sizeBytes ||
            await digestService.digestFile(file) != entry.sha256) {
          throw const QigongBackupException('media_hash_mismatch');
        }
      }
      final checksum = File(
        p.joinAll([package.path, ...p.posix.split(_checksumRelativePath)]),
      );
      if (!await checksum.exists() ||
          await checksum.readAsString() !=
              _checksumText(expectedDatabaseHash, manifestEntries)) {
        throw const QigongBackupException('checksum_contract_mismatch');
      }
      await _requireExactFiles(package, manifestEntries);
      return QigongBackupEvidence(
        schemaVersion: evidence.schemaVersion,
        mediaCount: manifestEntries.length,
        databaseSha256: expectedDatabaseHash,
      );
    } on QigongBackupException {
      rethrow;
    } on Object {
      throw const QigongBackupException('backup_validation_failed');
    }
  }

  Future<void> restoreBackup(Directory package) async {
    await validateBackup(package);
    for (final suffix in <String>['-wal', '-shm', '-journal']) {
      if (await File('${sourceDatabaseFile.path}$suffix').exists()) {
        throw const QigongBackupException('live_database_sidecar_present');
      }
    }
    final token = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    final stageRoot = Directory(
      p.join(profileRoot.path, '.qigong-restore-stage-$token'),
    );
    final rollbackDatabase = File('${sourceDatabaseFile.path}.rollback-$token');
    final liveMedia = Directory(p.join(profileRoot.path, 'qigong_media'));
    final rollbackMedia = Directory('${liveMedia.path}.rollback-$token');
    var databaseMoved = false;
    var mediaMoved = false;
    try {
      await stageRoot.create();
      final stageDatabase = File(
        p.join(stageRoot.path, p.basename(sourceDatabaseFile.path)),
      );
      final packageDatabase = File(
        p.joinAll([package.path, ...p.posix.split(_databaseRelativePath)]),
      );
      await packageDatabase.copy(stageDatabase.path);
      final entries = await _databaseMediaEntries(packageDatabase);
      for (final entry in entries) {
        final source = _packageMediaFile(package, entry.relativePath);
        final target = File(
          p.joinAll([stageRoot.path, ...p.posix.split(entry.relativePath)]),
        );
        await target.parent.create(recursive: true);
        await source.copy(target.path);
        if (await digestService.digestFile(target) != entry.sha256) {
          throw const QigongBackupException('restore_stage_hash_mismatch');
        }
      }
      if (await sourceDatabaseFile.exists()) {
        await sourceDatabaseFile.rename(rollbackDatabase.path);
        databaseMoved = true;
      }
      if (await liveMedia.exists()) {
        await liveMedia.rename(rollbackMedia.path);
        mediaMoved = true;
      }
      await stageDatabase.rename(sourceDatabaseFile.path);
      final stagedMedia = Directory(p.join(stageRoot.path, 'qigong_media'));
      if (await stagedMedia.exists()) await stagedMedia.rename(liveMedia.path);
      databaseInspector.inspectVerified(sourceDatabaseFile.path);
      for (final entry in entries) {
        final restored = _resolveProfileRelative(entry.relativePath);
        if (!await restored.exists() ||
            await digestService.digestFile(restored) != entry.sha256) {
          throw const QigongBackupException(
            'restored_media_verification_failed',
          );
        }
      }
      if (await rollbackDatabase.exists()) {
        await rollbackDatabase.delete();
      }
      if (await rollbackMedia.exists()) {
        await rollbackMedia.delete(recursive: true);
      }
      await _deleteIfExists(stageRoot);
    } on Object catch (error) {
      try {
        if (await sourceDatabaseFile.exists()) {
          await sourceDatabaseFile.delete();
        }
        if (databaseMoved && await rollbackDatabase.exists()) {
          await rollbackDatabase.rename(sourceDatabaseFile.path);
        }
        if (await liveMedia.exists()) await liveMedia.delete(recursive: true);
        if (mediaMoved && await rollbackMedia.exists()) {
          await rollbackMedia.rename(liveMedia.path);
        }
        await _deleteIfExists(stageRoot);
      } on Object {
        throw const QigongBackupException('restore_rollback_failed');
      }
      if (error is QigongBackupException) rethrow;
      throw const QigongBackupException('restore_failed');
    }
  }

  ResolvedBackupRecoveryPaths _resolvedPaths() => TarotBackupPathContract(
    sourceRootPath: profileRoot.path,
    backupRootPath: backupRoot.path,
    protectedRootPaths: const [],
  ).resolve();

  Future<List<_MediaEntry>> _databaseMediaEntries(File databaseFile) async {
    Database? database;
    try {
      database = sqlite3.open(databaseFile.path, mode: OpenMode.readOnly);
      final rows = database.select(
        'SELECT id, sha256, managed_relative_path, byte_size '
        'FROM qigong_media_assets ORDER BY id',
      );
      return rows
          .map(
            (row) => _MediaEntry(
              id: row['id']! as String,
              sha256: row['sha256']! as String,
              relativePath: row['managed_relative_path']! as String,
              sizeBytes: row['byte_size']! as int,
            ),
          )
          .toList(growable: false);
    } on SqliteException {
      throw const QigongBackupException('media_manifest_database_read_failed');
    } finally {
      database?.close();
    }
  }

  Map<String, Object?> _manifest({
    required DateTime createdAtUtc,
    required int databaseSize,
    required String databaseHash,
    required List<_MediaEntry> mediaEntries,
  }) => <String, Object?>{
    'backupFormatVersion': 1,
    'applicationIdentity': TarotBackupManifest.applicationIdentity,
    'contentScope': 'qigong_complete_document_media_v1',
    'createdAtUtc': createdAtUtc.toIso8601String(),
    'schemaVersion': TarotBackupManifest.schemaVersion,
    'databaseRelativePath': _databaseRelativePath,
    'databaseSizeBytes': databaseSize,
    'databaseSha256': databaseHash,
    'checksumRelativePath': _checksumRelativePath,
    'media': mediaEntries.map((entry) => entry.toJson()).toList(),
    'verificationResult': 'verified',
  };

  List<_MediaEntry> _manifestEntries(Object? source) {
    if (source is! List) {
      throw const QigongBackupException('media_manifest_invalid');
    }
    final entries = source.map(_MediaEntry.fromJson).toList(growable: false);
    final ids = entries.map((entry) => entry.id).toList();
    final sortedIds = [...ids]..sort();
    if (ids.toSet().length != ids.length || !_sameStrings(ids, sortedIds)) {
      throw const QigongBackupException('media_manifest_invalid');
    }
    return entries;
  }

  File _resolveProfileRelative(String relativePath) {
    _validateMediaRelativePath(relativePath);
    return File(p.joinAll([profileRoot.path, ...p.posix.split(relativePath)]));
  }

  File _packageMediaFile(Directory package, String relativePath) {
    _validateMediaRelativePath(relativePath);
    return File(
      p.joinAll([package.path, ...p.posix.split('$_mediaPrefix$relativePath')]),
    );
  }

  void _validateMediaRelativePath(String path) {
    if (p.posix.isAbsolute(path) ||
        !p.posix.isWithin('qigong_media', path) ||
        p.posix.split(path).any((part) => part == '..' || part == '.')) {
      throw const QigongBackupException('unsafe_media_relative_path');
    }
  }

  Future<void> _requireExactFiles(
    Directory package,
    List<_MediaEntry> mediaEntries,
  ) async {
    final expected = <String>{
      _manifestFilename,
      _databaseRelativePath,
      _checksumRelativePath,
      for (final entry in mediaEntries) '$_mediaPrefix${entry.relativePath}',
    };
    final actual = <String>{};
    await for (final entity in package.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is Link) {
        throw const QigongBackupException('package_link_forbidden');
      }
      if (entity is File) {
        actual.add(
          p.relative(entity.path, from: package.path).replaceAll('\\', '/'),
        );
      }
    }
    if (!_sameStrings(expected.toList()..sort(), actual.toList()..sort())) {
      throw const QigongBackupException('package_inventory_mismatch');
    }
  }

  String _checksumText(String databaseHash, List<_MediaEntry> entries) => [
    '$databaseHash  $_databaseRelativePath',
    for (final entry in entries)
      '${entry.sha256}  $_mediaPrefix${entry.relativePath}',
    '',
  ].join('\n');

  void _validateIdentity(DateTime createdAtUtc, String operationId) {
    if (!createdAtUtc.isUtc ||
        !RegExp(r'^[0-9a-f]{8}$').hasMatch(operationId)) {
      throw const QigongBackupException('invalid_backup_identity');
    }
  }
}

final class _MediaEntry {
  const _MediaEntry({
    required this.id,
    required this.sha256,
    required this.relativePath,
    required this.sizeBytes,
  });

  factory _MediaEntry.fromJson(Object? source) {
    if (source is! Map<String, dynamic> ||
        source.keys.join('|') != 'id|sha256|relativePath|sizeBytes') {
      throw const QigongBackupException('media_manifest_invalid');
    }
    final id = source['id'];
    final sha256 = source['sha256'];
    final relativePath = source['relativePath'];
    final sizeBytes = source['sizeBytes'];
    if (id is! String ||
        id.isEmpty ||
        sha256 is! String ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(sha256) ||
        relativePath is! String ||
        sizeBytes is! int ||
        sizeBytes < 0) {
      throw const QigongBackupException('media_manifest_invalid');
    }
    return _MediaEntry(
      id: id,
      sha256: sha256,
      relativePath: relativePath,
      sizeBytes: sizeBytes,
    );
  }

  final String id;
  final String sha256;
  final String relativePath;
  final int sizeBytes;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'sha256': sha256,
    'relativePath': relativePath,
    'sizeBytes': sizeBytes,
  };
}

bool _sameMediaEntries(List<_MediaEntry> left, List<_MediaEntry> right) =>
    left.length == right.length &&
    Iterable<int>.generate(left.length).every(
      (index) =>
          left[index].id == right[index].id &&
          left[index].sha256 == right[index].sha256 &&
          left[index].relativePath == right[index].relativePath &&
          left[index].sizeBytes == right[index].sizeBytes,
    );

bool _sameStrings(List<String> left, List<String> right) =>
    left.length == right.length &&
    Iterable<int>.generate(
      left.length,
    ).every((index) => left[index] == right[index]);

String _timestamp(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}'
    '${value.month.toString().padLeft(2, '0')}'
    '${value.day.toString().padLeft(2, '0')}'
    'T${value.hour.toString().padLeft(2, '0')}'
    '${value.minute.toString().padLeft(2, '0')}'
    '${value.second.toString().padLeft(2, '0')}Z';

Future<void> _deleteIfExists(Directory directory) async {
  if (await directory.exists()) await directory.delete(recursive: true);
}
