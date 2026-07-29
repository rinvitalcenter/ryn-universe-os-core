import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/runtime/ryn_runtime_services.dart';
import 'package:ryn_universe_os_core/core/theme/ryn_tokens.dart';
import 'package:ryn_universe_os_core/features/qigong_blog/domain/qigong_blog_models.dart';
import 'package:ryn_universe_os_core/features/qigong_blog/presentation/qigong_blog_shell.dart';
import 'package:ryn_universe_os_core/features/qigong_blog/presentation/qigong_document_studio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RynAppDatabase database;
  late RynRuntimeServices services;
  late Directory profileRoot;

  setUp(() async {
    database = RynAppDatabase(NativeDatabase.memory());
    profileRoot = await Directory.systemTemp.createTemp('ryn-qigong-widget-');
    services = RynRuntimeServices(database, profileRootPath: profileRoot.path);
    await _seedStudio(services, profileRoot);
  });

  tearDown(() async {
    await database.close();
    if (await profileRoot.exists()) await profileRoot.delete(recursive: true);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'studio ${brightness.name} smoke exposes editor AI gallery and publication ledger',
      (tester) async {
        tester.view.physicalSize = const Size(1600, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _app(brightness: brightness, services: services),
        );
        await tester.pumpAndSettle();

        expect(find.text('수련 작업실'), findsOneWidget);
        expect(find.text('새 수련기'), findsAtLeastNWidgets(1));
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('긴 호흡 뒤의 고요'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('qigong-reading-view')), findsOneWidget);
        expect(find.text('첫 문단은 느린 호흡으로 시작한다.'), findsOneWidget);

        await tester.tap(find.text('편집').last);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('qigong-document-editor')), findsOneWidget);

        await tester.tap(find.text('AI 작업'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('qigong-ai-draft-field')), findsOneWidget);

        await tester.tap(find.text('이미지').first);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('qigong-media-grid-4-6')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('발행'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('qigong-publication-ledger')),
          findsOneWidget,
        );
        expect(find.text('네이버 카페 · 기공도가'), findsOneWidget);
        expect(find.text('다음 카페 · 기공마을'), findsOneWidget);
        expect(find.text('네이버 블로그 · 명린연구소'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pump(const Duration(milliseconds: 1));
      },
    );
  }

  testWidgets(
    'prompt history keeps expansion and scroll state type-safe per document',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final bucket = PageStorageBucket();
      final first = ValueNotifier(_promptDocument('prompt-post-first'));
      final second = ValueNotifier(_promptDocument('prompt-post-second'));
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      await tester.pumpWidget(
        _studioApp(
          brightness: Brightness.light,
          bucket: bucket,
          document: first,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('이미지'));
      await tester.pumpAndSettle();

      const workbenchKey = ValueKey('qigong-media-workbench');
      final workbench = find.descendant(
        of: find.byKey(workbenchKey).first,
        matching: find.byType(ListView),
      );
      final promptField = find.byKey(const Key('qigong-image-prompt-field'));
      final firstInitialTop = tester.getTopLeft(promptField).dy;
      await tester.enterText(promptField, 'quiet synthetic breath prompt');
      await tester.drag(workbench, const Offset(0, -240));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(promptField).dy, lessThan(firstInitialTop));

      await tester.ensureVisible(find.text('프롬프트 복사'));
      await tester.tap(find.text('프롬프트 복사'));
      await tester.pumpAndSettle();

      final insertionExceptions = <Object>[];
      Object? insertionException;
      while ((insertionException = tester.takeException()) != null) {
        insertionExceptions.add(insertionException!);
      }
      expect(insertionExceptions, isEmpty);
      expect(find.text('최근 프롬프트 1개'), findsOneWidget);
      await tester.tap(find.text('최근 프롬프트 1개'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);

      await tester.pumpWidget(
        _studioApp(
          brightness: Brightness.dark,
          bucket: bucket,
          document: first,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);

      await tester.tap(find.text('최근 프롬프트 1개'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.history_rounded), findsNothing);
      await tester.tap(find.text('최근 프롬프트 1개'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);

      await tester.pumpWidget(
        _studioApp(
          brightness: Brightness.dark,
          bucket: bucket,
          document: second,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('이미지'));
      await tester.pumpAndSettle();
      expect(find.text('최근 프롬프트 1개'), findsNothing);
      expect(
        tester.getTopLeft(promptField).dy,
        moreOrLessEquals(firstInitialTop, epsilon: 1),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('1366 desktop and 1.3 text scale have no overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1366, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: _app(brightness: Brightness.dark, services: services),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  });
}

Widget _app({
  required Brightness brightness,
  required RynRuntimeServices services,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: RynTheme.light(fontFamily: 'Arial', fontFamilyFallback: const []),
  darkTheme: RynTheme.dark(fontFamily: 'Arial', fontFamilyFallback: const []),
  themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
  home: Scaffold(
    body: QigongBlogShell(
      repository: services.qigongBlog,
      mediaStore: services.qigongMedia,
      pickImages: () async => const [],
    ),
  ),
);

Widget _studioApp({
  required Brightness brightness,
  required PageStorageBucket bucket,
  required ValueNotifier<QigongBlogDocument> document,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: RynTheme.light(fontFamily: 'Arial', fontFamilyFallback: const []),
  darkTheme: RynTheme.dark(fontFamily: 'Arial', fontFamilyFallback: const []),
  themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
  home: Scaffold(
    body: PageStorage(
      bucket: bucket,
      child: ValueListenableBuilder(
        valueListenable: document,
        builder: (context, value, child) => QigongDocumentStudio(
          key: ValueKey('test-studio-${value.post.id}'),
          document: value,
          mediaAssets: const [],
          mediaStore: null,
          onChanged: (next) => document.value = next,
          onImportImages: () async => const [],
        ),
      ),
    ),
  ),
);

QigongBlogDocument _promptDocument(String id) {
  final now = DateTime.utc(2026, 7, 29, 22);
  return QigongBlogDocument(
    post: QigongPost(
      id: id,
      title: 'Prompt storage $id',
      status: QigongPostStatus.drafting,
      createdAt: now,
      updatedAt: now,
    ),
    blocks: const [
      QigongPostBlock(
        id: 'prompt-block',
        type: QigongBlockType.paragraph,
        order: 0,
        text: 'Synthetic prompt history regression body.',
      ),
    ],
    tags: const [],
    publications: const [],
  );
}

Future<void> _seedStudio(RynRuntimeServices services, Directory root) async {
  final media = <QigongMediaAsset>[];
  for (var index = 0; index < 6; index++) {
    final file = File('${root.path}/synthetic-$index.png');
    await file.writeAsBytes(
      await _imageBytes(
        Color.fromARGB(255, 30 + index * 25, 70 + index * 17, 130 + index * 12),
      ),
    );
    final imported = await services.qigongMedia!.importImage(file);
    final stored = await services.qigongBlog.saveMediaAsset(
      imported.asset.copyWith(
        caption: '수련 이미지 ${index + 1}',
        altText: '합성 호흡 장면 ${index + 1}',
      ),
    );
    media.add(stored.value!);
  }
  final now = DateTime.utc(2026, 7, 29, 21);
  final document = QigongBlogDocument(
    post: QigongPost(
      id: 'qigong-post-widget',
      title: '긴 호흡 뒤의 고요',
      status: QigongPostStatus.finalPost,
      occurredAt: now,
      practiceDayNumber: 128,
      rawMemo: '어깨가 가벼워진 순간을 바로 적었다.',
      personalDraft: '호흡은 억지로 늘이지 않았고 자연스럽게 길어졌다.',
      aiWorkingDraft: '고요가 호흡 사이에 머물렀다는 초안.',
      imagePrompt: 'midnight blue breathing room, quiet photographic journal',
      promptHistory: const ['soft blue breath study'],
      keywords: const ['호흡', '저녁'],
      coverMediaId: media.first.id,
      createdAt: now,
      updatedAt: now,
    ),
    blocks: [
      const QigongPostBlock(
        id: 'b1',
        type: QigongBlockType.heading,
        order: 0,
        text: '고요가 머문 자리',
      ),
      const QigongPostBlock(
        id: 'b2',
        type: QigongBlockType.paragraph,
        order: 1,
        text: '첫 문단은 느린 호흡으로 시작한다.',
      ),
      const QigongPostBlock(
        id: 'b3',
        type: QigongBlockType.quote,
        order: 2,
        text: '서두르지 않을 때 몸이 먼저 길을 안다.',
      ),
      QigongPostBlock(
        id: 'b4',
        type: QigongBlockType.imageGallery,
        order: 3,
        galleryColumns: 4,
        mediaIds: media.map((asset) => asset.id).toList(),
      ),
      const QigongPostBlock(
        id: 'b5',
        type: QigongBlockType.imageCaption,
        order: 4,
        text: '합성 이미지로 구성한 수련 장면.',
      ),
    ],
    tags: const ['호흡', '저녁'],
    publications: const [
      QigongPublication(
        platform: QigongPublicationPlatform.naverCafeQigongDoga,
        status: QigongPublicationStatus.published,
        externalUrl: 'https://example.com/naver-cafe',
      ),
      QigongPublication(
        platform: QigongPublicationPlatform.daumCafeQigongVillage,
        status: QigongPublicationStatus.preparing,
      ),
      QigongPublication(
        platform: QigongPublicationPlatform.naverBlogMyeongrinLab,
        status: QigongPublicationStatus.notPublished,
      ),
    ],
  );
  final result = await services.qigongBlog.savePost(document);
  if (result.isFailure) throw result.error!;
}

Future<List<int>> _imageBytes(Color color) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(const Rect.fromLTWH(0, 0, 80, 60), Paint()..color = color);
  canvas.drawCircle(
    const Offset(40, 30),
    16,
    Paint()..color = Colors.white.withValues(alpha: 0.25),
  );
  final image = await recorder.endRecording().toImage(80, 60);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}
