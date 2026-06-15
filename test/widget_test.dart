import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';

import 'package:ryn_universe_os_core/core/text/app_text.dart';
import 'package:ryn_universe_os_core/main.dart';

void main() {
  testWidgets('renders REDESIGN4 Premium Core OS shell markers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RynUniverseApp());

    expect(find.text('Ryn Universe OS Core'), findsAtLeastNWidgets(1));
    expect(find.text('홈'), findsAtLeastNWidgets(1));
    expect(find.text('명령'), findsAtLeastNWidgets(1));
    expect(find.text('관제'), findsAtLeastNWidgets(1));
    expect(find.text('흐름'), findsAtLeastNWidgets(1));
    expect(find.text('기록'), findsAtLeastNWidgets(1));
    expect(find.text('산출'), findsAtLeastNWidgets(1));
    expect(find.text('설정'), findsAtLeastNWidgets(1));
    expect(find.text('린님 Daily Home'), findsOneWidget);
    expect(find.text('Command Hub'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('이어가기 준비됨'), findsOneWidget);
    expect(find.text('Chief / Governance Deck'), findsNothing);

    await tester.tap(find.text('명령'));
    await tester.pumpAndSettle();

    expect(find.text('AI Command Center'), findsAtLeastNWidgets(1));
    expect(find.text('Home / Command Hub'), findsOneWidget);
    expect(find.text('AI 전략 보고서 작성'), findsAtLeastNWidgets(1));
    expect(find.text('Mission Control Decision Surface'), findsOneWidget);
    expect(find.text(AppText.cmdStatusStaticMvpMode), findsAtLeastNWidgets(1));
    expect(
      find.text(AppText.cmdNextActionSpecAlignedPatch),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.text(AppText.cmdApprovalRiskBoundedSource),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Obsidian 보고 중심'), findsAtLeastNWidgets(1));
    expect(find.text(AppText.markerSpecMvpBaseline), findsAtLeastNWidgets(1));
    expect(
      find.text(AppText.markerApprovalPacketOnly),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Safety Status Strip'), findsOneWidget);
    expect(find.text('DB CLOSED / NO WRITE'), findsAtLeastNWidgets(1));
    expect(find.text('Gateway OFF'), findsAtLeastNWidgets(1));
    expect(find.text('Chief / Governance Deck'), findsOneWidget);
    expect(find.text('Construction Stage Map'), findsOneWidget);
    expect(find.text('공사 장부: GitHub 보관'), findsOneWidget);
    expect(find.text('다음 허가: Command Center UI 공사'), findsOneWidget);
    expect(find.text('Next Permit Queue'), findsOneWidget);
    expect(find.text('1순위 · Next Permit Queue'), findsOneWidget);
    expect(find.text('7-Profile Council Growth Plan'), findsOneWidget);
    expect(find.text('DB Schema Blueprint · 문서 전용'), findsOneWidget);
    expect(find.text('Council Growth Plan 문서'), findsOneWidget);
    expect(find.text('RYN-CORE-COUNCIL-GROWTH-PLAN1'), findsAtLeastNWidgets(1));
    expect(find.text('Obsidian AI Command Center 기록'), findsOneWidget);
    expect(find.text('DB Blueprint 문서'), findsOneWidget);
    expect(
      find.text('RYN-CORE-DB-SCHEMA-BLUEPRINT-DOC1'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('DB 구현 HOLD'), findsOneWidget);
    expect(find.text('External Automation Policy 문서'), findsOneWidget);
    expect(
      find.text('RYN-CORE-EXTERNAL-AUTOMATION-POLICY1'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('외부 자동화 HOLD'), findsOneWidget);
    expect(find.text('IA1: PASS WITH GUARDS'), findsAtLeastNWidgets(1));
    expect(find.text('Council Sessions'), findsOneWidget);
    expect(find.text('Obsidian Links'), findsOneWidget);
    expect(
      find.text('RYN-CORE-COMMAND-CENTER-IA1-spec'),
      findsAtLeastNWidgets(1),
    );

    expect(find.text('Hermes'), findsAtLeastNWidgets(1));
    expect(find.text('AI 운영 비서'), findsAtLeastNWidgets(1));
    expect(find.text('Codex'), findsAtLeastNWidgets(1));
    expect(find.text('7-Agent Council'), findsAtLeastNWidgets(1));
    expect(find.text('Obsidian'), findsAtLeastNWidgets(1));
    expect(find.text('Approval Gate'), findsAtLeastNWidgets(1));

    expect(find.text('정적 미리보기'), findsAtLeastNWidgets(1));
    expect(find.text('실제 Telegram 연동 없음'), findsAtLeastNWidgets(1));
    expect(find.text('실제 자동화 없음'), findsAtLeastNWidgets(1));

    expect(find.text('한서윤'), findsAtLeastNWidgets(1));
    expect(find.text('강도현'), findsAtLeastNWidgets(1));
    expect(find.text('윤지안'), findsAtLeastNWidgets(1));
    expect(find.text('서하린'), findsAtLeastNWidgets(1));
    expect(find.text('이유진'), findsAtLeastNWidgets(1));
    expect(find.text('차민준'), findsAtLeastNWidgets(1));
    expect(find.text('문서아'), findsAtLeastNWidgets(1));

    expect(find.text('프로젝트'), findsAtLeastNWidgets(1));
    expect(find.text('문서'), findsAtLeastNWidgets(1));
    expect(find.text('AI 모델'), findsAtLeastNWidgets(1));
    expect(find.text('데이터'), findsAtLeastNWidgets(1));
    expect(find.text('자동화'), findsAtLeastNWidgets(1));
  });

  testWidgets('separates 린님 Home from Dev/Governance surface', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    expect(find.text('린님 Daily Home'), findsOneWidget);
    expect(find.text('Command Hub'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('이어가기 준비됨'), findsOneWidget);
    expect(find.text('Chief / Governance Deck'), findsNothing);
    expect(find.text('Safety Status Strip'), findsNothing);
    expect(find.text('DB CLOSED / NO WRITE'), findsNothing);
    expect(find.text('Mission Control Decision Surface'), findsNothing);

    await tester.tap(find.text('명령'));
    await tester.pumpAndSettle();

    expect(find.text('AI Command Center'), findsAtLeastNWidgets(1));
    expect(find.text('Chief / Governance Deck'), findsOneWidget);
    expect(find.text('Safety Status Strip'), findsOneWidget);
  });

  testWidgets('renders compact 364px client layout without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(364, 1129);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('명령'));
    await tester.pumpAndSettle();

    expect(find.text(AppText.cmdAiCommandCenter), findsAtLeastNWidgets(1));
    expect(find.text(AppText.markerNoTelegram), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text(AppText.kanbanTitleOrchestra));
    await tester.pumpAndSettle();

    expect(find.text(AppText.kanbanTitleOrchestra), findsOneWidget);
    expect(find.text(AppText.kanbanSnapshotTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps desktop capture content inside 1280 capture area', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('명령'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Governance / Record / Boundary'));
    await tester.pumpAndSettle();

    final commandSurfaceRect = tester.getRect(
      find
          .byWidgetPredicate(
            (widget) => widget.runtimeType.toString() == '_CommandSurface',
          )
          .first,
    );
    final governanceSurfaceRect = tester.getRect(
      find
          .byWidgetPredicate(
            (widget) => widget.runtimeType.toString() == '_GovernanceSurface',
          )
          .first,
    );

    expect(commandSurfaceRect.right, lessThanOrEqualTo(1280));
    expect(governanceSurfaceRect.right, lessThanOrEqualTo(1280));
    expect(tester.takeException(), isNull);
  });

  testWidgets('selects a static Kanban card and shows inspection-only detail', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('명령'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(AppText.kanbanTitleOrchestra));
    await tester.pumpAndSettle();

    expect(find.text(AppText.kanbanSnapshotTitle), findsOneWidget);
    expect(find.text(AppText.kanbanSnapshotBaselineValue), findsOneWidget);
    expect(find.text(AppText.kanbanSnapshotNextSliceValue), findsOneWidget);
    expect(find.text(AppText.kanbanSnapshotBoundaryValue), findsOneWidget);

    expect(find.text(AppText.kanbanSelectionNoneSelected), findsOneWidget);
    expect(find.text(AppText.kanbanMsgSelectCardToPreview), findsOneWidget);

    await tester.ensureVisible(find.text('KANBAN-ORCH3'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('KANBAN-ORCH3'));
    await tester.pumpAndSettle();

    expect(
      find.text(AppText.kanbanSelectionCardSelected),
      findsAtLeastNWidgets(1),
    );
    expect(find.text(AppText.kanbanDetailTaskSummary), findsOneWidget);
    expect(find.text(AppText.kanbanDetailRecordStatus), findsOneWidget);
    expect(
      find.text(AppText.kanbanDetailBoundarySignal),
      findsAtLeastNWidgets(1),
    );
    expect(find.text(AppText.kanbanDetailInspectionOnlyNote), findsOneWidget);
    expect(find.text(AppText.markerNoLaneMovement), findsAtLeastNWidgets(1));
    expect(find.text(AppText.markerNoDragDrop), findsAtLeastNWidgets(1));
  });
}
