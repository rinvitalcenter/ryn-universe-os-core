import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/features/qigong_blog/application/qigong_blog_controller.dart';
import 'package:ryn_universe_os_core/core/runtime/ryn_runtime_services.dart';

void main() {
  late RynAppDatabase database;
  late RynRuntimeServices services;
  late Directory profileRoot;
  late QigongBlogController controller;

  setUp(() async {
    database = RynAppDatabase(NativeDatabase.memory());
    profileRoot = await Directory.systemTemp.createTemp(
      'ryn-qigong-controller-',
    );
    services = RynRuntimeServices(database, profileRootPath: profileRoot.path);
    controller = QigongBlogController(
      repository: services.qigongBlog,
      mediaStore: services.qigongMedia,
    );
    await controller.initialize();
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
    if (await profileRoot.exists()) await profileRoot.delete(recursive: true);
  });

  test(
    'duplicate save is rejected while one aggregate save is active',
    () async {
      final created = controller.createNewPost(now: DateTime.utc(2026, 7, 29));
      controller.updateDocument(
        created.copyWith(
          post: created.post.copyWith(title: '호흡이 길어진 저녁'),
          blocks: [created.blocks.single.copyWith(text: '천천히 이어진 호흡을 기록한다.')],
        ),
      );

      final first = controller.save();
      final duplicate = await controller.save();

      expect(duplicate, isFalse);
      expect(await first, isTrue);
      expect(controller.saveState, QigongSaveState.saved);
    },
  );

  test('failed save preserves the unsaved document exactly', () async {
    final created = controller.createNewPost(now: DateTime.utc(2026, 7, 29));
    controller.updateDocument(
      created.copyWith(
        post: created.post.copyWith(title: ''),
        blocks: [created.blocks.single.copyWith(text: '지우면 안 되는 미완성 원문')],
      ),
    );
    final pending = controller.document!;

    expect(await controller.save(), isFalse);
    expect(controller.document, same(pending));
    expect(controller.document!.plainText, '지우면 안 되는 미완성 원문');
    expect(controller.saveState, QigongSaveState.failed);
    expect(controller.errorMessage, contains('그대로 보존'));
  });

  test('duplicate media import keeps one canonical DB asset', () async {
    final source = File('${profileRoot.path}/source.png');
    await source.writeAsBytes(_pngBytes);

    final imported = await controller.importImages([source, source]);
    await Future<void>.delayed(Duration.zero);

    expect(imported, hasLength(2));
    final count = await database
        .customSelect('SELECT COUNT(*) AS c FROM qigong_media_assets')
        .getSingle();
    expect(count.read<int>('c'), 1);
    expect(services.qigongMedia!.resolve(imported.first).existsSync(), isTrue);
  });
}

const _pngBytes = <int>[
  137,
  80,
  78,
  71,
  13,
  10,
  26,
  10,
  0,
  0,
  0,
  13,
  73,
  72,
  68,
  82,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  1,
  8,
  6,
  0,
  0,
  0,
  31,
  21,
  196,
  137,
  0,
  0,
  0,
  13,
  73,
  68,
  65,
  84,
  8,
  215,
  99,
  248,
  207,
  192,
  240,
  31,
  0,
  5,
  0,
  1,
  255,
  137,
  153,
  61,
  29,
  0,
  0,
  0,
  0,
  73,
  69,
  78,
  68,
  174,
  66,
  96,
  130,
];
