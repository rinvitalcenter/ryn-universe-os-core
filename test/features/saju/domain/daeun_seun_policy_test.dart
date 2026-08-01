import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/saju/domain/daeun_seun_policy.dart';

void main() {
  group('CheonEulGwiIn V5.20 Daeun/Seun policy identity', () {
    test('publishes the exact approved engine and reference metadata', () {
      expect(CheonEulGwiInV520DaeunSeunPolicy.engineId, 'rynSajuDaeunSeun');
      expect(CheonEulGwiInV520DaeunSeunPolicy.engineVersion, '1.0.0');
      expect(
        CheonEulGwiInV520DaeunSeunPolicy.policyId,
        'cheonEulGwiInV520TraditionalAgeDaeunSeunV1',
      );
      expect(CheonEulGwiInV520DaeunSeunPolicy.policyVersion, '1.0.0');
      expect(
        CheonEulGwiInV520DaeunSeunPolicy.referenceProductId,
        'cheonEulGwiIn',
      );
      expect(CheonEulGwiInV520DaeunSeunPolicy.referenceVersion, '5.20');
      expect(CheonEulGwiInV520DaeunSeunPolicy.fixtureSet, 'CEG-DS-BATCH1');
    });

    test('publishes each approved component version exactly', () {
      expect(
        CheonEulGwiInV520DaeunSeunPolicy.directionRuleVersion,
        'yearStemYinYangGenderV1',
      );
      expect(
        CheonEulGwiInV520DaeunSeunPolicy.termSelectionVersion,
        'forwardNextReversePreviousMonthlyJieV1',
      );
      expect(
        CheonEulGwiInV520DaeunSeunPolicy.daeunNumberVersion,
        'threeDaysNearestIntegerMinimumOneV1',
      );
      expect(
        CheonEulGwiInV520DaeunSeunPolicy.firstCycleVersion,
        'natalMonthPlusMinusOneV1',
      );
      expect(
        CheonEulGwiInV520DaeunSeunPolicy.cycleSequenceVersion,
        'sexagenaryElevenCyclesTenYearsV1',
      );
      expect(
        CheonEulGwiInV520DaeunSeunPolicy.ageModeVersion,
        'traditionalKoreanStartYearV1',
      );
      expect(
        CheonEulGwiInV520DaeunSeunPolicy.unknownTimeVersion,
        'stableCivilDayResultOrFailClosedV1',
      );
      expect(
        CheonEulGwiInV520DaeunSeunPolicy.seunVersion,
        'annualSexagenaryLabelOnlyV1',
      );
      expect(
        CheonEulGwiInV520DaeunSeunPolicy.seunBoundaryVersion,
        'referenceNotExposedV1',
      );
      expect(
        CheonEulGwiInV520DaeunSeunPolicy.tenGodVersion,
        'natalDayStemBranchMainQiV1',
      );
    });

    test('limits v1 to traditional age and annual-label Seun', () {
      expect(CheonEulGwiInV520DaeunSeunPolicy.ageMode, 'traditionalKorean');
      expect(CheonEulGwiInV520DaeunSeunPolicy.daeunCycleCount, 11);
      expect(CheonEulGwiInV520DaeunSeunPolicy.daeunCycleYears, 10);
      expect(CheonEulGwiInV520DaeunSeunPolicy.minimumSeunYear, 1990);
      expect(CheonEulGwiInV520DaeunSeunPolicy.maximumSeunYear, 2159);
      expect(
        CheonEulGwiInV520DaeunSeunPolicy.claimsSeunTimestampBoundary,
        isFalse,
      );
    });
  });
}
