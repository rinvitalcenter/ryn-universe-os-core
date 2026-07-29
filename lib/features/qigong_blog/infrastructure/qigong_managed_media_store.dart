import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/backup_recovery/sha256_digest_service.dart';
import '../domain/qigong_blog_models.dart';

final class QigongMediaImportResult {
  const QigongMediaImportResult({required this.asset, required this.duplicate});

  final QigongMediaAsset asset;
  final bool duplicate;
}

final class QigongManagedMediaStore {
  QigongManagedMediaStore({
    required Directory profileRoot,
    Sha256DigestService digestService = const DartSha256DigestService(),
  }) : this._(profileRoot, digestService);

  QigongManagedMediaStore._(this._profileRoot, this._digestService);

  static const managedDirectoryName = 'qigong_media';
  final Directory _profileRoot;
  final Sha256DigestService _digestService;

  Directory get managedRoot =>
      Directory(p.join(_profileRoot.path, managedDirectoryName));

  Future<QigongMediaImportResult> importImage(File source) async {
    if (!await source.exists()) {
      throw StateError('선택한 이미지 파일을 찾을 수 없습니다.');
    }
    final extension = p.extension(source.path).toLowerCase();
    final mimeType = switch (extension) {
      '.png' => 'image/png',
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.webp' => 'image/webp',
      _ => throw ArgumentError.value(
        extension,
        'source',
        'PNG, JPEG, WebP 이미지만 가져올 수 있습니다.',
      ),
    };
    final sha256 = await _digestService.digestFile(source);
    final normalizedExtension = extension == '.jpeg' ? '.jpg' : extension;
    final relativePath = p.posix.join(
      managedDirectoryName,
      sha256.substring(0, 2),
      '$sha256$normalizedExtension',
    );
    final destination = File(
      p.joinAll(<String>[_profileRoot.path, ...p.posix.split(relativePath)]),
    );
    final duplicate = await destination.exists();
    if (duplicate) {
      final storedHash = await _digestService.digestFile(destination);
      if (storedHash != sha256) {
        throw StateError('동일한 media identity의 관리 파일이 손상되었습니다.');
      }
    } else {
      await destination.parent.create(recursive: true);
      final temporary = File('${destination.path}.partial');
      if (await temporary.exists()) await temporary.delete();
      try {
        await source.copy(temporary.path);
        final copiedHash = await _digestService.digestFile(temporary);
        if (copiedHash != sha256) {
          throw StateError('이미지 안전 사본의 hash 검증에 실패했습니다.');
        }
        await temporary.rename(destination.path);
      } finally {
        if (await temporary.exists()) await temporary.delete();
      }
    }
    final stat = await destination.stat();
    return QigongMediaImportResult(
      duplicate: duplicate,
      asset: QigongMediaAsset(
        id: 'qigong-media-${sha256.substring(0, 24)}',
        sha256: sha256,
        managedRelativePath: relativePath,
        originalFileName: p.basename(source.path),
        mimeType: mimeType,
        byteSize: stat.size,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  File resolve(QigongMediaAsset asset) {
    final relative = asset.managedRelativePath;
    if (p.posix.isAbsolute(relative) ||
        !p.posix.isWithin(managedDirectoryName, relative)) {
      throw StateError('관리 media 상대 경로 계약을 벗어났습니다.');
    }
    return File(
      p.joinAll(<String>[_profileRoot.path, ...p.posix.split(relative)]),
    );
  }

  Future<bool> verify(QigongMediaAsset asset) async {
    final file = resolve(asset);
    if (!await file.exists()) return false;
    return await _digestService.digestFile(file) == asset.sha256;
  }
}
