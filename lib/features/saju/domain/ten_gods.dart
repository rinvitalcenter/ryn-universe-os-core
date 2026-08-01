import 'sexagenary_cycle.dart';

enum SajuFiveElement {
  wood('목'),
  fire('화'),
  earth('토'),
  metal('금'),
  water('수');

  const SajuFiveElement(this.label);

  final String label;
}

enum SajuTenGod {
  peer('비견'),
  robWealth('겁재'),
  foodGod('식신'),
  hurtingOfficer('상관'),
  indirectWealth('편재'),
  properWealth('정재'),
  indirectOfficer('편관'),
  properOfficer('정관'),
  indirectResource('편인'),
  properResource('정인');

  const SajuTenGod(this.label);

  final String label;
}

abstract final class SajuStemNature {
  static SajuFiveElement elementForStem(int stemIndex) {
    RangeError.checkValidIndex(
      stemIndex,
      SexagenaryRegistry.stems,
      'stemIndex',
    );
    return SajuFiveElement.values[stemIndex ~/ 2];
  }

  static bool isYang(int stemIndex) {
    RangeError.checkValidIndex(
      stemIndex,
      SexagenaryRegistry.stems,
      'stemIndex',
    );
    return stemIndex.isEven;
  }
}

abstract final class SajuBranchMainQiRegistry {
  static const _mainQiStemIndexes = <int>[9, 5, 0, 1, 4, 2, 3, 5, 6, 7, 4, 8];

  static HeavenlyStem stemForBranch(int branchIndex) {
    RangeError.checkValidIndex(
      branchIndex,
      SexagenaryRegistry.branches,
      'branchIndex',
    );
    return SexagenaryRegistry.stems[_mainQiStemIndexes[branchIndex]];
  }
}

abstract final class SajuTenGodCalculator {
  static SajuTenGod calculate({
    required int dayStemIndex,
    required int targetStemIndex,
  }) {
    final dayElement = SajuStemNature.elementForStem(dayStemIndex).index;
    final targetElement = SajuStemNature.elementForStem(targetStemIndex).index;
    final samePolarity =
        SajuStemNature.isYang(dayStemIndex) ==
        SajuStemNature.isYang(targetStemIndex);

    if (targetElement == dayElement) {
      return samePolarity ? SajuTenGod.peer : SajuTenGod.robWealth;
    }
    if (targetElement == (dayElement + 1) % 5) {
      return samePolarity ? SajuTenGod.foodGod : SajuTenGod.hurtingOfficer;
    }
    if (targetElement == (dayElement + 2) % 5) {
      return samePolarity ? SajuTenGod.indirectWealth : SajuTenGod.properWealth;
    }
    if (dayElement == (targetElement + 1) % 5) {
      return samePolarity
          ? SajuTenGod.indirectResource
          : SajuTenGod.properResource;
    }
    return samePolarity ? SajuTenGod.indirectOfficer : SajuTenGod.properOfficer;
  }

  static SajuTenGod forBranchMainQi({
    required int dayStemIndex,
    required int branchIndex,
  }) => calculate(
    dayStemIndex: dayStemIndex,
    targetStemIndex: SajuBranchMainQiRegistry.stemForBranch(branchIndex).index,
  );
}
