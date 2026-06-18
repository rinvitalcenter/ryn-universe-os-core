import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/study_os/data/schema/study_os_schema_draft.dart';

void main() {
  group('StudyOsSchemaDraft', () {
    test('contains every approved MVP entity', () {
      const expectedEntities = <String>{
        'StudySession',
        'Member',
        'AttendanceRecord',
        'Material',
        'StudySessionMaterial',
        'JournalEntry',
        'ReportSummary',
        'LocalSetting',
      };

      expect(StudyOsSchemaDraft.mvpEntityNames, expectedEntities);
      expect(StudyOsSchemaDraft.entities, hasLength(expectedEntities.length));
    });

    test('keeps protected later scope out of MVP entities', () {
      final entityNames = StudyOsSchemaDraft.mvpEntityNames;

      for (final protectedName in StudyOsSchemaDraft.protectedLaterScope) {
        expect(entityNames, isNot(contains(protectedName)));
      }

      expect(
        StudyOsSchemaDraft.protectedLaterScope,
        containsAll(<String>{
          'birth data',
          'counseling notes',
          'saju/tarot/astrology/human-design data',
          'health/personal notes',
        }),
      );
    });

    test('is static metadata only', () {
      expect(StudyOsSchemaDraft.isRuntimeDatabase, isFalse);
      expect(StudyOsSchemaDraft.definesTables, isFalse);
      expect(StudyOsSchemaDraft.definesMigrations, isFalse);
      expect(StudyOsSchemaDraft.definesSchemaVersion, isFalse);
      expect(StudyOsSchemaDraft.opensOrWritesDatabase, isFalse);

      for (final entity in StudyOsSchemaDraft.entities) {
        expect(entity.isConceptualOnly, isTrue);
        expect(entity.fieldConcepts, isNotEmpty);
      }
    });
  });
}
