import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/tarot/application/tarot_runtime_controller.dart';
import 'package:ryn_universe_os_core/main.dart';

void main() {
  testWidgets('ready runtime shows restrained development-data indicator', (
    tester,
  ) async {
    final controller = TarotRuntimeController.presentationTest();

    await tester.pumpWidget(
      RynUniverseApp(runtimeController: controller, bootstrapOnStart: false),
    );
    await tester.pump();

    expect(find.text('개발 데이터'), findsOneWidget);
    final tooltip = tester.widget<Tooltip>(
      find.byKey(const Key('development-data-indicator')),
    );
    expect(tooltip.message, '현재 기록은 개발용 데이터에 저장됩니다.');
    await tester.pumpWidget(const SizedBox());
    await controller.close();
  });

  testWidgets('recoveryRequired never renders as an honest empty Home', (
    tester,
  ) async {
    final controller = TarotRuntimeController.presentationTest(
      status: TarotRuntimeStartupStatus.recoveryRequired,
    );

    await tester.pumpWidget(
      RynUniverseApp(runtimeController: controller, bootstrapOnStart: false),
    );
    await tester.pump();

    expect(find.text('저장된 기록을 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('기존 데이터 파일은 변경하지 않았습니다.'), findsOneWidget);
    expect(find.byKey(const Key('runtime-bootstrap-retry')), findsOneWidget);
    expect(find.byKey(const Key('home-cinematic-scene')), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await controller.close();
  });

  test('Windows metadata freezes approved display identity only', () {
    final runner = File('windows/runner/Runner.rc').readAsStringSync();
    final main = File('windows/runner/main.cpp').readAsStringSync();
    expect(runner, contains('VALUE "CompanyName", "Rin Vital Center"'));
    expect(runner, contains('VALUE "ProductName", "Ryn Universe OS"'));
    expect(runner, contains('VALUE "InternalName", "ryn_universe_os_core"'));
    expect(main, contains('L"Ryn Universe OS"'));
  });
}
