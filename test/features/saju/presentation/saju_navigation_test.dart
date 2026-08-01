import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
