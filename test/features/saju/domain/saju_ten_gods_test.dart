import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/saju/domain/sexagenary_cycle.dart';
import 'package:ryn_universe_os_core/features/saju/domain/ten_gods.dart';

void main() {
  const expectedMatrix = <List<String>>[
    ['비견', '겁재', '식신', '상관', '편재', '정재', '편관', '정관', '편인', '정인'],
    ['겁재', '비견', '상관', '식신', '정재', '편재', '정관', '편관', '정인', '편인'],
    ['편인', '정인', '비견', '겁재', '식신', '상관', '편재', '정재', '편관', '정관'],
    ['정인', '편인', '겁재', '비견', '상관', '식신', '정재', '편재', '정관', '편관'],
    ['편관', '정관', '편인', '정인', '비견', '겁재', '식신', '상관', '편재', '정재'],
    ['정관', '편관', '정인', '편인', '겁재', '비견', '상관', '식신', '정재', '편재'],
    ['편재', '정재', '편관', '정관', '편인', '정인', '비견', '겁재', '식신', '상관'],
    ['정재', '편재', '정관', '편관', '정인', '편인', '겁재', '비견', '상관', '식신'],
    ['식신', '상관', '편재', '정재', '편관', '정관', '편인', '정인', '비견', '겁재'],
    ['상관', '식신', '정재', '편재', '정관', '편관', '정인', '편인', '겁재', '비견'],
  ];

  test('10 by 10 heavenly stem relationship matrix is canonical', () {
    for (var dayStemIndex = 0; dayStemIndex < 10; dayStemIndex++) {
      for (var targetStemIndex = 0; targetStemIndex < 10; targetStemIndex++) {
        expect(
          SajuTenGodCalculator.calculate(
            dayStemIndex: dayStemIndex,
            targetStemIndex: targetStemIndex,
          ).label,
          expectedMatrix[dayStemIndex][targetStemIndex],
          reason: 'day=$dayStemIndex target=$targetStemIndex',
        );
      }
    }
  });

  test('self relationship is always 비견', () {
    for (var stemIndex = 0; stemIndex < 10; stemIndex++) {
      expect(
        SajuTenGodCalculator.calculate(
          dayStemIndex: stemIndex,
          targetStemIndex: stemIndex,
        ),
        SajuTenGod.peer,
      );
    }
  });

  test('yin and yang distinguish proper from indirect ten gods', () {
    expect(
      SajuTenGodCalculator.calculate(dayStemIndex: 0, targetStemIndex: 4),
      SajuTenGod.indirectWealth,
    );
    expect(
      SajuTenGodCalculator.calculate(dayStemIndex: 0, targetStemIndex: 5),
      SajuTenGod.properWealth,
    );
    expect(
      SajuTenGodCalculator.calculate(dayStemIndex: 2, targetStemIndex: 8),
      SajuTenGod.indirectOfficer,
    );
    expect(
      SajuTenGodCalculator.calculate(dayStemIndex: 2, targetStemIndex: 9),
      SajuTenGod.properOfficer,
    );
  });

  test('five-element generate and control relationships are explicit', () {
    expect(SajuStemNature.elementForStem(0), SajuFiveElement.wood);
    expect(SajuStemNature.elementForStem(2), SajuFiveElement.fire);
    expect(SajuStemNature.elementForStem(4), SajuFiveElement.earth);
    expect(SajuStemNature.elementForStem(6), SajuFiveElement.metal);
    expect(SajuStemNature.elementForStem(8), SajuFiveElement.water);

    expect(
      SajuTenGodCalculator.calculate(dayStemIndex: 0, targetStemIndex: 2),
      SajuTenGod.foodGod,
    );
    expect(
      SajuTenGodCalculator.calculate(dayStemIndex: 0, targetStemIndex: 4),
      SajuTenGod.indirectWealth,
    );
    expect(
      SajuTenGodCalculator.calculate(dayStemIndex: 0, targetStemIndex: 6),
      SajuTenGod.indirectOfficer,
    );
    expect(
      SajuTenGodCalculator.calculate(dayStemIndex: 0, targetStemIndex: 8),
      SajuTenGod.indirectResource,
    );
  });

  test('12 branches map to canonical main-qi stems', () {
    const expectedStemIndexes = [9, 5, 0, 1, 4, 2, 3, 5, 6, 7, 4, 8];

    for (var branchIndex = 0; branchIndex < 12; branchIndex++) {
      final stem = SajuBranchMainQiRegistry.stemForBranch(branchIndex);
      expect(stem.index, expectedStemIndexes[branchIndex]);
      expect(stem, same(SexagenaryRegistry.stems[stem.index]));
    }
  });

  test('known 丙 day fixture derives stem and branch main-qi ten gods', () {
    const dayStemIndex = 2;

    expect(
      SajuTenGodCalculator.calculate(
        dayStemIndex: dayStemIndex,
        targetStemIndex: 9,
      ),
      SajuTenGod.properOfficer,
    );
    expect(
      SajuTenGodCalculator.forBranchMainQi(
        dayStemIndex: dayStemIndex,
        branchIndex: 5,
      ),
      SajuTenGod.peer,
    );
    expect(
      SajuTenGodCalculator.forBranchMainQi(
        dayStemIndex: dayStemIndex,
        branchIndex: 2,
      ),
      SajuTenGod.indirectResource,
    );
  });
}
