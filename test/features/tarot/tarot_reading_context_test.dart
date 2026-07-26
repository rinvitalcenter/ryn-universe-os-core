import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_context.dart';
import 'package:ryn_universe_os_core/features/tarot/tarot_spread_shell.dart';

void main() {
  group('TarotReadingContext', () {
    test('self context accepts a null Person reference', () {
      final context = TarotReadingContext.self(
        sessionId: 'session-self-001',
        sourceContext: TarotReadingSourceContext.home,
      );

      expect(context.mode, TarotReadingMode.self);
      expect(context.personId, isNull);
    });

    test('practice context accepts a null Person reference', () {
      final context = TarotReadingContext.practice(
        sessionId: 'session-practice-001',
        sourceContext: TarotReadingSourceContext.study,
      );

      expect(context.mode, TarotReadingMode.practice);
      expect(context.personId, isNull);
    });

    test('person context accepts a canonical non-empty Person ID', () {
      final context = TarotReadingContext.person(
        sessionId: 'session-person-001',
        sourceContext: TarotReadingSourceContext.people,
        personId: 'person-test-001',
      );

      expect(context.mode, TarotReadingMode.person);
      expect(context.personId, 'person-test-001');
    });

    test('person context rejects a null Person ID', () {
      expect(
        () => TarotReadingContext.validated(
          mode: TarotReadingMode.person,
          sourceContext: TarotReadingSourceContext.people,
          sessionId: 'session-person-null',
        ),
        throwsArgumentError,
      );
    });

    test('person context rejects an empty Person ID', () {
      expect(
        () => TarotReadingContext.person(
          sessionId: 'session-person-empty',
          sourceContext: TarotReadingSourceContext.people,
          personId: '',
        ),
        throwsArgumentError,
      );
    });

    test('person context rejects a whitespace-only Person ID', () {
      expect(
        () => TarotReadingContext.person(
          sessionId: 'session-person-whitespace',
          sourceContext: TarotReadingSourceContext.people,
          personId: '   ',
        ),
        throwsArgumentError,
      );
    });

    test('self context rejects a non-null Person ID', () {
      expect(
        () => TarotReadingContext.validated(
          mode: TarotReadingMode.self,
          sourceContext: TarotReadingSourceContext.reading,
          sessionId: 'session-self-invalid',
          personId: 'person-test-001',
        ),
        throwsArgumentError,
      );
    });

    test('practice context rejects a non-null Person ID', () {
      expect(
        () => TarotReadingContext.validated(
          mode: TarotReadingMode.practice,
          sourceContext: TarotReadingSourceContext.study,
          sessionId: 'session-practice-invalid',
          personId: 'person-test-001',
        ),
        throwsArgumentError,
      );
    });

    test('source context is explicit and type-safe', () {
      final contexts = TarotReadingSourceContext.values;

      expect(
        contexts,
        containsAll(<TarotReadingSourceContext>[
          TarotReadingSourceContext.home,
          TarotReadingSourceContext.people,
          TarotReadingSourceContext.reading,
          TarotReadingSourceContext.study,
        ]),
      );
      expect(contexts, hasLength(4));
    });

    test('default Reading entry uses self mode with no Person', () {
      final context = TarotReadingContext.defaultReading(
        sessionId: 'session-default-001',
      );

      expect(context.mode, TarotReadingMode.self);
      expect(context.personId, isNull);
      expect(context.sourceContext, TarotReadingSourceContext.reading);
    });

    test('explicit transitions preserve the active session identity', () {
      final initial = TarotReadingContext.defaultReading(
        sessionId: 'session-transition-001',
      );

      final person = initial.toPerson(
        personId: 'person-test-001',
        sourceContext: TarotReadingSourceContext.people,
      );
      final practice = person.toPractice(
        sourceContext: TarotReadingSourceContext.study,
      );

      expect(person.sessionId, initial.sessionId);
      expect(person.personId, 'person-test-001');
      expect(practice.sessionId, initial.sessionId);
      expect(practice.mode, TarotReadingMode.practice);
      expect(practice.personId, isNull);
    });
  });

  testWidgets('existing Tarot entry initializes one default self context', (
    WidgetTester tester,
  ) async {
    final initialized = <TarotReadingContext>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarotSpreadShell(
            onBack: () {},
            onReadingContextInitialized: initialized.add,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(initialized, hasLength(1));
    expect(initialized.single.mode, TarotReadingMode.self);
    expect(initialized.single.personId, isNull);
    expect(initialized.single.sourceContext, TarotReadingSourceContext.reading);
    expect(initialized.single.sessionId, isNotEmpty);
  });
}
