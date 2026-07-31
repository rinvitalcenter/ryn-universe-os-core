import 'saju_models.dart';

int positiveModulo(int value, int modulus) =>
    ((value % modulus) + modulus) % modulus;

final class HeavenlyStem {
  const HeavenlyStem({
    required this.index,
    required this.hanja,
    required this.koreanLabel,
  });

  final int index;
  final String hanja;
  final String koreanLabel;
}

final class EarthlyBranch {
  const EarthlyBranch({
    required this.index,
    required this.hanja,
    required this.koreanLabel,
  });

  final int index;
  final String hanja;
  final String koreanLabel;
}

final class SexagenaryEntry {
  const SexagenaryEntry({
    required this.canonicalId,
    required this.cycleIndex,
    required this.stemIndex,
    required this.branchIndex,
    required this.hanja,
    required this.koreanLabel,
  });

  final String canonicalId;
  final int cycleIndex;
  final int stemIndex;
  final int branchIndex;
  final String hanja;
  final String koreanLabel;

  Map<String, Object> toJson() => {
    'canonicalId': canonicalId,
    'cycleIndex': cycleIndex,
    'stemIndex': stemIndex,
    'branchIndex': branchIndex,
    'hanja': hanja,
    'koreanLabel': koreanLabel,
  };
}

abstract final class SexagenaryRegistry {
  static const stems = <HeavenlyStem>[
    HeavenlyStem(index: 0, hanja: '甲', koreanLabel: '갑'),
    HeavenlyStem(index: 1, hanja: '乙', koreanLabel: '을'),
    HeavenlyStem(index: 2, hanja: '丙', koreanLabel: '병'),
    HeavenlyStem(index: 3, hanja: '丁', koreanLabel: '정'),
    HeavenlyStem(index: 4, hanja: '戊', koreanLabel: '무'),
    HeavenlyStem(index: 5, hanja: '己', koreanLabel: '기'),
    HeavenlyStem(index: 6, hanja: '庚', koreanLabel: '경'),
    HeavenlyStem(index: 7, hanja: '辛', koreanLabel: '신'),
    HeavenlyStem(index: 8, hanja: '壬', koreanLabel: '임'),
    HeavenlyStem(index: 9, hanja: '癸', koreanLabel: '계'),
  ];

  static const branches = <EarthlyBranch>[
    EarthlyBranch(index: 0, hanja: '子', koreanLabel: '자'),
    EarthlyBranch(index: 1, hanja: '丑', koreanLabel: '축'),
    EarthlyBranch(index: 2, hanja: '寅', koreanLabel: '인'),
    EarthlyBranch(index: 3, hanja: '卯', koreanLabel: '묘'),
    EarthlyBranch(index: 4, hanja: '辰', koreanLabel: '진'),
    EarthlyBranch(index: 5, hanja: '巳', koreanLabel: '사'),
    EarthlyBranch(index: 6, hanja: '午', koreanLabel: '오'),
    EarthlyBranch(index: 7, hanja: '未', koreanLabel: '미'),
    EarthlyBranch(index: 8, hanja: '申', koreanLabel: '신'),
    EarthlyBranch(index: 9, hanja: '酉', koreanLabel: '유'),
    EarthlyBranch(index: 10, hanja: '戌', koreanLabel: '술'),
    EarthlyBranch(index: 11, hanja: '亥', koreanLabel: '해'),
  ];

  static final List<SexagenaryEntry> cycle = List<SexagenaryEntry>.unmodifiable(
    List.generate(60, (index) {
      final stem = stems[index % stems.length];
      final branch = branches[index % branches.length];
      return SexagenaryEntry(
        canonicalId: 'sexagenary-${index.toString().padLeft(2, '0')}',
        cycleIndex: index,
        stemIndex: stem.index,
        branchIndex: branch.index,
        hanja: '${stem.hanja}${branch.hanja}',
        koreanLabel: '${stem.koreanLabel}${branch.koreanLabel}',
      );
    }),
  );

  static SexagenaryEntry byIndex(int index) => cycle[positiveModulo(index, 60)];

  static SexagenaryEntry byStemAndBranch(int stemIndex, int branchIndex) =>
      cycle.singleWhere(
        (entry) =>
            entry.stemIndex == positiveModulo(stemIndex, 10) &&
            entry.branchIndex == positiveModulo(branchIndex, 12),
      );
}

final class SexagenaryCalculator {
  static const dayAnchorVersion = 'gregorian-jdn-plus49-v1';

  SexagenaryEntry dayPillar(SajuLocalDate localCivilDate) {
    if (!localCivilDate.isValid) {
      throw const SajuCalculationException(
        code: SajuErrorCode.invalidDate,
        userMessage: '유효한 날짜를 입력해 주세요.',
      );
    }
    final jdn = _gregorianJulianDayNumber(localCivilDate);
    return SexagenaryRegistry.byIndex(positiveModulo(jdn + 49, 60));
  }

  SexagenaryEntry yearPillar(int solarTermYear) =>
      SexagenaryRegistry.byIndex(positiveModulo(solarTermYear - 4, 60));

  SexagenaryEntry monthPillar({
    required int yearStemIndex,
    required int monthOffset,
  }) {
    final firstMonthStem = positiveModulo((yearStemIndex % 5) * 2 + 2, 10);
    return SexagenaryRegistry.byStemAndBranch(
      firstMonthStem + monthOffset,
      2 + monthOffset,
    );
  }

  SexagenaryEntry hourPillar({
    required int dayStemIndex,
    required int observedHour,
  }) {
    final branchIndex = positiveModulo((observedHour + 1) ~/ 2, 12);
    final firstHourStem = positiveModulo((dayStemIndex % 5) * 2, 10);
    return SexagenaryRegistry.byStemAndBranch(
      firstHourStem + branchIndex,
      branchIndex,
    );
  }

  int _gregorianJulianDayNumber(SajuLocalDate date) {
    final a = (14 - date.month) ~/ 12;
    final y = date.year + 4800 - a;
    final m = date.month + 12 * a - 3;
    return date.day +
        ((153 * m + 2) ~/ 5) +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }
}
