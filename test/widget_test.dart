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

    expect(find.text('AI Command Center'), findsAtLeastNWidgets(1));
    expect(find.text('Home / Command Hub'), findsOneWidget);
    expect(find.text('AI 전략 보고서 작성'), findsAtLeastNWidgets(1));
    expect(find.text('Mission Control Decision Surface'), findsOneWidget);
    expect(find.text(AppText.cmdStatusStaticMvpMode), findsAtLeastNWidgets(1));
    expect(find.text(AppText.cmdNextActionSpecAlignedPatch), findsAtLeastNWidgets(1));
    expect(find.text(AppText.cmdApprovalRiskBoundedSource), findsAtLeastNWidgets(1));
    expect(find.text('Obsidian 보고 중심'), findsAtLeastNWidgets(1));
    expect(find.text(AppText.markerSpecMvpBaseline), findsAtLeastNWidgets(1));
    expect(find.text(AppText.markerApprovalPacketOnly), findsAtLeastNWidgets(1));

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

  testWidgets('selects a static Kanban card and shows inspection-only detail', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RynUniverseApp());

    await tester.ensureVisible(find.text(AppText.kanbanTitleOrchestra));
    await tester.pumpAndSettle();

    expect(find.text(AppText.kanbanSelectionNoneSelected), findsOneWidget);
    expect(find.text(AppText.kanbanMsgSelectCardToPreview), findsOneWidget);

    await tester.ensureVisible(find.text('KANBAN-ORCH3'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('KANBAN-ORCH3'));
    await tester.pumpAndSettle();

    expect(find.text(AppText.kanbanSelectionCardSelected), findsAtLeastNWidgets(1));
    expect(find.text(AppText.kanbanDetailTaskSummary), findsOneWidget);
    expect(find.text(AppText.kanbanDetailInspectionOnlyNote), findsOneWidget);
    expect(find.text(AppText.markerNoLaneMovement), findsAtLeastNWidgets(1));
    expect(find.text(AppText.markerNoDragDrop), findsAtLeastNWidgets(1));
  });
}
