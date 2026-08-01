import 'saju_snapshot.dart';
import 'sexagenary_cycle.dart';
import 'ten_gods.dart';

enum DaeunDirection { forward, reverse }

enum DaeunSeunErrorCode {
  genderRequired,
  invalidInterval,
  invalidSnapshot,
  unknownTimeAmbiguous,
  unsupportedForecastHorizon,
  unsupportedSeunYear,
}

enum DaeunSeunWarningCode {
  unknownTimeStableCivilDay,
  seunTimestampBoundaryNotExposed,
}

final class DaeunSeunCalculationException implements Exception {
  const DaeunSeunCalculationException({
    required this.code,
    required this.userMessage,
    this.detail,
  });

  final DaeunSeunErrorCode code;
  final String userMessage;
  final String? detail;

  @override
  String toString() =>
      'DaeunSeunCalculationException(${code.name}): $userMessage'
      '${detail == null ? '' : ' ($detail)'}';
}

final class DaeunSeunMetadata {
  const DaeunSeunMetadata({
    required this.engineId,
    required this.engineVersion,
    required this.policyId,
    required this.policyVersion,
    required this.referenceProductId,
    required this.referenceVersion,
    required this.fixtureSet,
    required this.directionRuleVersion,
    required this.termSelectionVersion,
    required this.daeunNumberVersion,
    required this.firstCycleVersion,
    required this.cycleSequenceVersion,
    required this.ageModeVersion,
    required this.unknownTimeVersion,
    required this.seunVersion,
    required this.seunBoundaryVersion,
    required this.tenGodVersion,
    required this.baseEngineId,
    required this.baseEngineVersion,
    required this.basePolicyId,
    required this.basePolicyVersion,
    required this.baseTimezoneId,
    required this.baseBirthPlaceProfile,
    required this.baseYajaEnabled,
    required this.baseSolarTermAlgorithmVersion,
    required this.baseTimeScaleAdapterVersion,
    required this.baseDayPillarId,
    required this.sourceSnapshotReference,
  });

  final String engineId;
  final String engineVersion;
  final String policyId;
  final String policyVersion;
  final String referenceProductId;
  final String referenceVersion;
  final String fixtureSet;
  final String directionRuleVersion;
  final String termSelectionVersion;
  final String daeunNumberVersion;
  final String firstCycleVersion;
  final String cycleSequenceVersion;
  final String ageModeVersion;
  final String unknownTimeVersion;
  final String seunVersion;
  final String seunBoundaryVersion;
  final String tenGodVersion;
  final String baseEngineId;
  final String baseEngineVersion;
  final String basePolicyId;
  final String basePolicyVersion;
  final String baseTimezoneId;
  final String baseBirthPlaceProfile;
  final bool baseYajaEnabled;
  final String baseSolarTermAlgorithmVersion;
  final String baseTimeScaleAdapterVersion;
  final String baseDayPillarId;
  final String sourceSnapshotReference;

  Map<String, Object> toJson() => {
    'engineId': engineId,
    'engineVersion': engineVersion,
    'policyId': policyId,
    'policyVersion': policyVersion,
    'referenceProductId': referenceProductId,
    'referenceVersion': referenceVersion,
    'fixtureSet': fixtureSet,
    'directionRuleVersion': directionRuleVersion,
    'termSelectionVersion': termSelectionVersion,
    'daeunNumberVersion': daeunNumberVersion,
    'firstCycleVersion': firstCycleVersion,
    'cycleSequenceVersion': cycleSequenceVersion,
    'ageModeVersion': ageModeVersion,
    'unknownTimeVersion': unknownTimeVersion,
    'seunVersion': seunVersion,
    'seunBoundaryVersion': seunBoundaryVersion,
    'tenGodVersion': tenGodVersion,
    'baseEngineId': baseEngineId,
    'baseEngineVersion': baseEngineVersion,
    'basePolicyId': basePolicyId,
    'basePolicyVersion': basePolicyVersion,
    'baseTimezoneId': baseTimezoneId,
    'baseBirthPlaceProfile': baseBirthPlaceProfile,
    'baseYajaEnabled': baseYajaEnabled,
    'baseSolarTermAlgorithmVersion': baseSolarTermAlgorithmVersion,
    'baseTimeScaleAdapterVersion': baseTimeScaleAdapterVersion,
    'baseDayPillarId': baseDayPillarId,
    'sourceSnapshotReference': sourceSnapshotReference,
  };
}

final class DaeunCycle {
  const DaeunCycle({
    required this.sequence,
    required this.pillar,
    required this.startTraditionalAge,
    required this.startYear,
    required this.endYearExclusive,
    required this.heavenlyStemTenGod,
    required this.earthlyBranchMainQiTenGod,
    required this.stemFiveElement,
    required this.branchFiveElement,
  });

  final int sequence;
  final SexagenaryEntry pillar;
  final int startTraditionalAge;
  final int startYear;
  final int endYearExclusive;
  final SajuTenGod heavenlyStemTenGod;
  final SajuTenGod earthlyBranchMainQiTenGod;
  final SajuFiveElement stemFiveElement;
  final SajuFiveElement branchFiveElement;

  Map<String, Object> toJson() => {
    'sequence': sequence,
    'pillar': pillar.toJson(),
    'startTraditionalAge': startTraditionalAge,
    'startYear': startYear,
    'endYearExclusive': endYearExclusive,
    'heavenlyStemTenGod': heavenlyStemTenGod.name,
    'earthlyBranchMainQiTenGod': earthlyBranchMainQiTenGod.name,
    'stemFiveElement': stemFiveElement.name,
    'branchFiveElement': branchFiveElement.name,
  };
}

final class DaeunCalculationResult {
  DaeunCalculationResult({
    required this.direction,
    required this.daeunNumber,
    required this.firstStartTraditionalAge,
    required this.firstStartYear,
    required DateTime selectedJieUtc,
    required this.intervalMicroseconds,
    required this.minimumIntervalMicroseconds,
    required this.maximumIntervalMicroseconds,
    required List<DaeunCycle> cycles,
    required List<DaeunSeunWarningCode> warnings,
    required this.metadata,
    required this.sourceSnapshotReference,
    required this.evaluatedMinuteCandidates,
  }) : selectedJieUtc = selectedJieUtc.toUtc(),
       cycles = List.unmodifiable(cycles),
       warnings = List.unmodifiable(warnings);

  final DaeunDirection direction;
  final int daeunNumber;
  final int firstStartTraditionalAge;
  final int firstStartYear;
  final DateTime selectedJieUtc;

  /// Exact only for a known birth time; null for unknown-time calculations.
  final int? intervalMicroseconds;
  final int minimumIntervalMicroseconds;
  final int maximumIntervalMicroseconds;
  final List<DaeunCycle> cycles;
  final List<DaeunSeunWarningCode> warnings;
  final DaeunSeunMetadata metadata;
  final String sourceSnapshotReference;
  final int evaluatedMinuteCandidates;

  Map<String, Object?> toJson() => {
    'direction': direction.name,
    'daeunNumber': daeunNumber,
    'firstStartTraditionalAge': firstStartTraditionalAge,
    'firstStartYear': firstStartYear,
    'selectedJieUtc': selectedJieUtc.toIso8601String(),
    'intervalMicroseconds': intervalMicroseconds,
    'minimumIntervalMicroseconds': minimumIntervalMicroseconds,
    'maximumIntervalMicroseconds': maximumIntervalMicroseconds,
    'cycles': cycles.map((cycle) => cycle.toJson()).toList(growable: false),
    'warnings': warnings.map((warning) => warning.name).toList(growable: false),
    'metadata': metadata.toJson(),
    'sourceSnapshotReference': sourceSnapshotReference,
    'evaluatedMinuteCandidates': evaluatedMinuteCandidates,
  };
}

final class SeunAnnualEntry {
  const SeunAnnualEntry({
    required this.gregorianYear,
    required this.pillar,
    required this.heavenlyStemTenGod,
    required this.earthlyBranchMainQiTenGod,
    required this.stemFiveElement,
    required this.branchFiveElement,
    required this.metadata,
  });

  final int gregorianYear;
  final SexagenaryEntry pillar;
  final SajuTenGod heavenlyStemTenGod;
  final SajuTenGod earthlyBranchMainQiTenGod;
  final SajuFiveElement stemFiveElement;
  final SajuFiveElement branchFiveElement;
  final DaeunSeunMetadata metadata;

  Map<String, Object> toJson() => {
    'gregorianYear': gregorianYear,
    'pillar': pillar.toJson(),
    'heavenlyStemTenGod': heavenlyStemTenGod.name,
    'earthlyBranchMainQiTenGod': earthlyBranchMainQiTenGod.name,
    'stemFiveElement': stemFiveElement.name,
    'branchFiveElement': branchFiveElement.name,
    'metadata': metadata.toJson(),
  };
}

DaeunSeunMetadata baseMetadataFromSnapshot(
  SajuChartSnapshot snapshot, {
  required String engineId,
  required String engineVersion,
  required String policyId,
  required String policyVersion,
  required String referenceProductId,
  required String referenceVersion,
  required String fixtureSet,
  required String directionRuleVersion,
  required String termSelectionVersion,
  required String daeunNumberVersion,
  required String firstCycleVersion,
  required String cycleSequenceVersion,
  required String ageModeVersion,
  required String unknownTimeVersion,
  required String seunVersion,
  required String seunBoundaryVersion,
  required String tenGodVersion,
}) => DaeunSeunMetadata(
  engineId: engineId,
  engineVersion: engineVersion,
  policyId: policyId,
  policyVersion: policyVersion,
  referenceProductId: referenceProductId,
  referenceVersion: referenceVersion,
  fixtureSet: fixtureSet,
  directionRuleVersion: directionRuleVersion,
  termSelectionVersion: termSelectionVersion,
  daeunNumberVersion: daeunNumberVersion,
  firstCycleVersion: firstCycleVersion,
  cycleSequenceVersion: cycleSequenceVersion,
  ageModeVersion: ageModeVersion,
  unknownTimeVersion: unknownTimeVersion,
  seunVersion: seunVersion,
  seunBoundaryVersion: seunBoundaryVersion,
  tenGodVersion: tenGodVersion,
  baseEngineId: snapshot.engineId,
  baseEngineVersion: snapshot.engineVersion,
  basePolicyId: snapshot.policyId,
  basePolicyVersion: snapshot.policyVersion,
  baseTimezoneId: snapshot.timezoneId,
  baseBirthPlaceProfile: snapshot.birthPlaceProfile,
  baseYajaEnabled: snapshot.yajaEnabled,
  baseSolarTermAlgorithmVersion: snapshot.solarTermAlgorithmVersion,
  baseTimeScaleAdapterVersion: snapshot.timeScaleAdapterVersion,
  baseDayPillarId: snapshot.dayPillar.canonicalId,
  sourceSnapshotReference: snapshot.deterministicSignature,
);
