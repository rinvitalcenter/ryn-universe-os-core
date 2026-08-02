import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/runtime/ryn_runtime_services.dart';
import 'package:ryn_universe_os_core/main.dart';

void main() {
  testWidgets('global navigation enters the Saju workspace', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RynUniverseApp(bootstrapOnStart: false));
    await tester.pumpAndSettle();

    final destination = find.byKey(const Key('ryn-nav-saju'));
    expect(destination, findsOneWidget);
    await tester.ensureVisible(destination);
    await tester.tap(destination);
    await tester.pumpAndSettle();

    expect(find.text('사주'), findsWidgets);
    expect(find.text('사주 기록을 열 수 없습니다.'), findsOneWidget);
  });

  testWidgets('loaded Saju destination owns natal Daeun and Seun tabs', (
    tester,
  ) async {
    final database = RynAppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final services = RynRuntimeServices(database);
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      RynUniverseApp(runtimeServices: services, bootstrapOnStart: false),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ryn-nav-saju')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('saju-tab-natal')), findsOneWidget);
    expect(find.byKey(const Key('saju-tab-daeun')), findsOneWidget);
    expect(find.byKey(const Key('saju-tab-seun')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
