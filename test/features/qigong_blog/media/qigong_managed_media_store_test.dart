import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:ryn_universe_os_core/features/qigong_blog/infrastructure/qigong_managed_media_store.dart';

void main() {
  late Directory root;
  late QigongManagedMediaStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('ryn-qigong-media-');
    store = QigongManagedMediaStore(profileRoot: root);
  });

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  test(
    'imports a managed copy with relative identity and survives source deletion',
    () async {
      final source = File(p.join(root.path, 'source', 'synthetic.png'));
      await source.parent.create(recursive: true);
      await source.writeAsBytes(_syntheticPng, flush: true);

      final imported = await store.importImage(source);
      expect(imported.duplicate, isFalse);
      expect(p.isAbsolute(imported.asset.managedRelativePath), isFalse);
      expect(imported.asset.managedRelativePath, startsWith('qigong_media'));
      final managed = store.resolve(imported.asset);
      expect(managed.existsSync(), isTrue);

      await source.delete();
      expect(managed.existsSync(), isTrue);
      expect(await store.verify(imported.asset), isTrue);
    },
  );

  test('deduplicates identical bytes by SHA-256', () async {
    final first = File(p.join(root.path, 'first.png'));
    final second = File(p.join(root.path, 'second.png'));
    await first.writeAsBytes(_syntheticPng, flush: true);
    await second.writeAsBytes(_syntheticPng, flush: true);

    final a = await store.importImage(first);
    final b = await store.importImage(second);

    expect(b.duplicate, isTrue);
    expect(b.asset.id, a.asset.id);
    expect(b.asset.managedRelativePath, a.asset.managedRelativePath);
    expect(
      await Directory(
        p.join(root.path, 'qigong_media'),
      ).list(recursive: true).where((entity) => entity is File).length,
      1,
    );
  });

  test('detects a managed media hash mismatch', () async {
    final source = File(p.join(root.path, 'source.jpg'));
    await source.writeAsBytes(_syntheticJpeg, flush: true);
    final imported = await store.importImage(source);
    await store.resolve(imported.asset).writeAsBytes([1, 2, 3], flush: true);

    expect(await store.verify(imported.asset), isFalse);
  });
}

final Uint8List _syntheticPng = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4e,
  0x47,
  0x0d,
  0x0a,
  0x1a,
  0x0a,
  0x00,
  0x00,
  0x00,
  0x00,
]);
final Uint8List _syntheticJpeg = Uint8List.fromList(const [
  0xff,
  0xd8,
  0xff,
  0xd9,
]);
