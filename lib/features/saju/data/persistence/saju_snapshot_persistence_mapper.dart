import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/backup_recovery/sha256_digest_service.dart';
import '../../../../core/persistence/app_database.dart';
import '../../domain/saju_models.dart';
import '../../domain/saju_policy.dart';
import '../../domain/saju_snapshot_repository.dart';
import '../../domain/sexagenary_cycle.dart';

final class SajuSnapshotValidationException implements Exception {
  const SajuSnapshotValidationException(this.message);
  final String message;
}

final class SajuSnapshotPersistenceMapper {
  const SajuSnapshotPersistenceMapper({
    Sha256DigestService? digests,
  }) : _digests = digests ?? const DartSha256DigestService();

  final Sha256DigestService _digests;

  SajuChartSnapshotsCompanion toCompanion({
    required String id,
    required String personId,
    required String? sourceBirthProfileId,
    required String chartGroupId,
    required int revisionNumber,
    required SajuRevisionReason revisionReason,
    required int createdAtUtcUs,
    required SajuChartSnapshot snapshot,
  }) {
    _validateMetadata(
      id: id,
      personId: personId,
      sourceBirthProfileId: sourceBirthProfileId,
      chartGroupId: chartGroupId,
      revisionNumber: revisionNumber,
      revisionReason: revisionReason,
      createdAtUtcUs: createdAtUtcUs,
    );
    _validateSnapshot(snapshot);
    final originalLunar = snapshot.originalLunarDate;
    final hour = snapshot.hourPillar;
    final warningsJson = jsonEncode(
      snapshot.warnings.map((warning) => warning.name).toList(growable: false),
    );
    return SajuChartSnapshotsCompanion.insert(
      id: id,
      personId: personId,
      sourceBirthProfileId: Value(sourceBirthProfileId),
      chartGroupId: chartGroupId,
      revisionNumber: revisionNumber,
      revisionReason: revisionReason.name,
      createdAtUtcUs: createdAtUtcUs,
      calculatedAtUtcUs: snapshot.calculatedAt.microsecondsSinceEpoch,
      calendarType: snapshot.calendarType.name,
      inputLocalDate: snapshot.originalInputDate,
      inputLocalTime: Value(snapshot.inputLocalTime?.iso8601),
      hourUnknown: snapshot.hourUnknown,
      genderCompatibilityValue: snapshot.gender.name,
      originalLunarYear: Value(originalLunar?.year),
      originalLunarMonth: Value(originalLunar?.month),
      originalLunarDay: Value(originalLunar?.day),
      originalLunarLeapMonth: Value(originalLunar?.isLeapMonth),
      timezoneId: snapshot.timezoneId,
      birthPlaceProfile: snapshot.birthPlaceProfile,
      yajaEnabled: snapshot.yajaEnabled,
      convertedSolarDate: snapshot.convertedSolarDate.iso8601,
      convertedLunarDate: snapshot.convertedLunarDate.iso8601.substring(0, 10),
      convertedLunarLeapMonth: snapshot.convertedLunarLeapMonth,
      birthUtcInstantUs: Value(
        snapshot.birthUtcInstant?.microsecondsSinceEpoch,
      ),
      utcOffsetAtBirthMinutes: snapshot.utcOffsetAtBirthMinutes,
      effectiveHourCalculationTime: Value(
        snapshot.effectiveHourCalculationTime?.toIso8601String(),
      ),
      yearPillarCanonicalId: snapshot.yearPillar.canonicalId,
      yearPillarCycleIndex: snapshot.yearPillar.cycleIndex,
      yearPillarStemIndex: snapshot.yearPillar.stemIndex,
      yearPillarBranchIndex: snapshot.yearPillar.branchIndex,
      yearPillarHanja: snapshot.yearPillar.hanja,
      yearPillarKoreanLabel: snapshot.yearPillar.koreanLabel,
      monthPillarCanonicalId: snapshot.monthPillar.canonicalId,
      monthPillarCycleIndex: snapshot.monthPillar.cycleIndex,
      monthPillarStemIndex: snapshot.monthPillar.stemIndex,
      monthPillarBranchIndex: snapshot.monthPillar.branchIndex,
      monthPillarHanja: snapshot.monthPillar.hanja,
      monthPillarKoreanLabel: snapshot.monthPillar.koreanLabel,
      dayPillarCanonicalId: snapshot.dayPillar.canonicalId,
      dayPillarCycleIndex: snapshot.dayPillar.cycleIndex,
      dayPillarStemIndex: snapshot.dayPillar.stemIndex,
      dayPillarBranchIndex: snapshot.dayPillar.branchIndex,
      dayPillarHanja: snapshot.dayPillar.hanja,
      dayPillarKoreanLabel: snapshot.dayPillar.koreanLabel,
      hourPillarCanonicalId: Value(hour?.canonicalId),
      hourPillarCycleIndex: Value(hour?.cycleIndex),
      hourPillarStemIndex: Value(hour?.stemIndex),
      hourPillarBranchIndex: Value(hour?.branchIndex),
      hourPillarHanja: Value(hour?.hanja),
      hourPillarKoreanLabel: Value(hour?.koreanLabel),
      engineId: snapshot.engineId,
      engineVersion: snapshot.engineVersion,
      policyId: snapshot.policyId,
      policyVersion: snapshot.policyVersion,
      dayRolloverPolicy: snapshot.dayRolloverPolicy,
      longitudeCorrectionPolicy: snapshot.longitudeCorrectionPolicy,
      dstCorrectionPolicy: snapshot.dstCorrectionPolicy,
      supportedRangeVersion: snapshot.supportedRangeVersion,
      solarTermAlgorithmVersion: snapshot.solarTermAlgorithmVersion,
      lunarConverterVersion: snapshot.lunarConverterVersion,
      dayAnchorVersion: snapshot.dayAnchorVersion,
      timeScaleAdapterVersion: snapshot.timeScaleAdapterVersion,
      warningsJson: warningsJson,
      inputFingerprintSha256: inputFingerprint(snapshot),
      calculationSignatureSha256: calculationSignature(snapshot),
    );
  }

  SajuPersistedSnapshot fromRow(SajuChartSnapshotRow row) {
    final warnings = _decodeWarnings(row.warningsJson);
    final solarDate = _parseSolarDate(row.convertedSolarDate);
    final lunarDate = _parseLunarDate(
      row.convertedLunarDate,
      isLeapMonth: row.convertedLunarLeapMonth,
    );
    final originalLunar = row.originalLunarYear == null
        ? null
        : KoreanLunarDate(
            row.originalLunarYear!,
            row.originalLunarMonth!,
            row.originalLunarDay!,
            isLeapMonth: row.originalLunarLeapMonth!,
          );
    final inputTime = row.inputLocalTime == null
        ? null
        : _parseLocalTime(row.inputLocalTime!);
    final snapshot = SajuChartSnapshot(
      engineId: row.engineId,
      engineVersion: row.engineVersion,
      policyId: row.policyId,
      policyVersion: row.policyVersion,
      timezoneId: row.timezoneId,
      calendarType: _calendarType(row.calendarType),
      lunarLeapMonth: row.originalLunarLeapMonth ?? false,
      dayRolloverPolicy: row.dayRolloverPolicy,
      yajaEnabled: row.yajaEnabled,
      longitudeCorrectionPolicy: row.longitudeCorrectionPolicy,
      dstCorrectionPolicy: row.dstCorrectionPolicy,
      supportedRangeVersion: row.supportedRangeVersion,
      solarTermAlgorithmVersion: row.solarTermAlgorithmVersion,
      lunarConverterVersion: row.lunarConverterVersion,
      dayAnchorVersion: row.dayAnchorVersion,
      timeScaleAdapterVersion: row.timeScaleAdapterVersion,
      originalInputDate: row.inputLocalDate,
      inputLocalTime: inputTime,
      gender: _gender(row.genderCompatibilityValue),
      birthPlaceProfile: row.birthPlaceProfile,
      inputLocalDateTime: inputTime == null
          ? '${solarDate.iso8601}Tunknown'
          : '${solarDate.iso8601}T${inputTime.iso8601}',
      utcOffsetAtBirthMinutes: row.utcOffsetAtBirthMinutes,
      convertedSolarDate: solarDate,
      convertedLunarDate: lunarDate,
      birthUtcInstant: row.birthUtcInstantUs == null
          ? null
          : DateTime.fromMicrosecondsSinceEpoch(
              row.birthUtcInstantUs!,
              isUtc: true,
            ),
      effectiveHourCalculationTime:
          row.effectiveHourCalculationTime == null
          ? null
          : DateTime.parse(row.effectiveHourCalculationTime!).toUtc(),
      originalLunarDate: originalLunar,
      hourUnknown: row.hourUnknown,
      yearPillar: _pillar(
        row.yearPillarCanonicalId,
        row.yearPillarCycleIndex,
        row.yearPillarStemIndex,
        row.yearPillarBranchIndex,
        row.yearPillarHanja,
        row.yearPillarKoreanLabel,
      ),
      monthPillar: _pillar(
        row.monthPillarCanonicalId,
        row.monthPillarCycleIndex,
        row.monthPillarStemIndex,
        row.monthPillarBranchIndex,
        row.monthPillarHanja,
        row.monthPillarKoreanLabel,
      ),
      dayPillar: _pillar(
        row.dayPillarCanonicalId,
        row.dayPillarCycleIndex,
        row.dayPillarStemIndex,
        row.dayPillarBranchIndex,
        row.dayPillarHanja,
        row.dayPillarKoreanLabel,
      ),
      hourPillar: row.hourPillarCycleIndex == null
          ? null
          : _pillar(
              row.hourPillarCanonicalId!,
              row.hourPillarCycleIndex!,
              row.hourPillarStemIndex!,
              row.hourPillarBranchIndex!,
              row.hourPillarHanja!,
              row.hourPillarKoreanLabel!,
            ),
      calculatedAt: DateTime.fromMicrosecondsSinceEpoch(
        row.calculatedAtUtcUs,
        isUtc: true,
      ),
      warnings: warnings,
    );
    _validateSnapshot(snapshot);
    if (inputFingerprint(snapshot) != row.inputFingerprintSha256 ||
        calculationSignature(snapshot) != row.calculationSignatureSha256) {
      throw const SajuSnapshotValidationException(
        'Stored Saju snapshot digest does not match its canonical payload.',
      );
    }
    return SajuPersistedSnapshot(
      id: row.id,
      personId: row.personId,
      sourceBirthProfileId: row.sourceBirthProfileId,
      chartGroupId: row.chartGroupId,
      revisionNumber: row.revisionNumber,
      revisionReason: SajuRevisionReason.values.byName(row.revisionReason),
      createdAtUtcUs: row.createdAtUtcUs,
      inputFingerprintSha256: row.inputFingerprintSha256,
      calculationSignatureSha256: row.calculationSignatureSha256,
      snapshot: snapshot,
    );
  }

  String inputFingerprint(SajuChartSnapshot snapshot) => _digest(
    jsonEncode({
      'calendarType': snapshot.calendarType.name,
      'originalInputDate': snapshot.originalInputDate,
      'inputLocalTime': snapshot.inputLocalTime?.toJson(),
      'hourUnknown': snapshot.hourUnknown,
      'gender': snapshot.gender.name,
      'originalLunarDate': snapshot.originalLunarDate?.toJson(),
      'timezoneId': snapshot.timezoneId,
      'birthPlaceProfile': snapshot.birthPlaceProfile,
      'yajaEnabled': snapshot.yajaEnabled,
    }),
  );

  String calculationSignature(SajuChartSnapshot snapshot) =>
      _digest(snapshot.deterministicSignature);

  void _validateMetadata({
    required String id,
    required String personId,
    required String? sourceBirthProfileId,
    required String chartGroupId,
    required int revisionNumber,
    required SajuRevisionReason revisionReason,
    required int createdAtUtcUs,
  }) {
    for (final value in [id, personId, chartGroupId]) {
      if (value.trim().isEmpty || value.length > 120) {
        throw const SajuSnapshotValidationException(
          'Snapshot identities must contain 1 to 120 characters.',
        );
      }
    }
    if (sourceBirthProfileId != null &&
        (sourceBirthProfileId.trim().isEmpty ||
            sourceBirthProfileId.length > 120)) {
      throw const SajuSnapshotValidationException(
        'Birth Profile identity is invalid.',
      );
    }
    if (revisionNumber < 1 || createdAtUtcUs < 0) {
      throw const SajuSnapshotValidationException(
        'Revision and timestamp values are invalid.',
      );
    }
    if ((revisionNumber == 1) !=
        (revisionReason == SajuRevisionReason.initial)) {
      throw const SajuSnapshotValidationException(
        'Initial revision reason does not match the revision number.',
      );
    }
  }

  void _validateSnapshot(SajuChartSnapshot snapshot) {
    if (snapshot.calculatedAt.microsecondsSinceEpoch < 0 ||
        snapshot.engineId != CheonEulGwiInModernKstPolicy.engineId ||
        snapshot.engineVersion != CheonEulGwiInModernKstPolicy.engineVersion ||
        snapshot.policyId != CheonEulGwiInModernKstPolicy.policyId ||
        snapshot.policyVersion != CheonEulGwiInModernKstPolicy.policyVersion ||
        snapshot.timezoneId != CheonEulGwiInModernKstPolicy.timezoneId ||
        snapshot.birthPlaceProfile !=
            CheonEulGwiInModernKstPolicy.birthPlaceProfile ||
        snapshot.yajaEnabled ||
        snapshot.dayRolloverPolicy !=
            CheonEulGwiInModernKstPolicy.dayRolloverPolicy ||
        snapshot.longitudeCorrectionPolicy !=
            CheonEulGwiInModernKstPolicy.longitudeCorrectionPolicy ||
        snapshot.dstCorrectionPolicy !=
            CheonEulGwiInModernKstPolicy.dstCorrectionPolicy ||
        snapshot.supportedRangeVersion !=
            CheonEulGwiInModernKstPolicy.supportedRangeVersion ||
        snapshot.utcOffsetAtBirthMinutes !=
            CheonEulGwiInModernKstPolicy.utcOffsetMinutes) {
      throw const SajuSnapshotValidationException(
        'Snapshot policy metadata is inconsistent.',
      );
    }
    if (snapshot.hourUnknown != (snapshot.inputLocalTime == null) ||
        snapshot.hourUnknown != (snapshot.hourPillar == null) ||
        snapshot.hourUnknown != (snapshot.birthUtcInstant == null) ||
        snapshot.hourUnknown !=
            (snapshot.effectiveHourCalculationTime == null)) {
      throw const SajuSnapshotValidationException(
        'Snapshot hour fields are incomplete.',
      );
    }
    if (!snapshot.convertedSolarDate.isValid ||
        !_validLunarDate(snapshot.convertedLunarDate) ||
        (snapshot.birthUtcInstant != null &&
            !snapshot.birthUtcInstant!.isUtc) ||
        (snapshot.effectiveHourCalculationTime != null &&
            !snapshot.effectiveHourCalculationTime!.isUtc)) {
      throw const SajuSnapshotValidationException(
        'Snapshot normalized outputs are invalid.',
      );
    }
    if (snapshot.calendarType == SajuCalendarType.solar &&
        (snapshot.originalLunarDate != null ||
            snapshot.originalInputDate != snapshot.convertedSolarDate.iso8601)) {
      throw const SajuSnapshotValidationException(
        'Solar input cannot contain original lunar fields.',
      );
    }
    if (snapshot.calendarType == SajuCalendarType.koreanLunar &&
        (snapshot.originalLunarDate == null ||
            !_validLunarDate(snapshot.originalLunarDate!) ||
            snapshot.originalInputDate != snapshot.originalLunarDate!.iso8601)) {
      throw const SajuSnapshotValidationException(
        'Lunar input requires original lunar fields.',
      );
    }
    _validatePillar(snapshot.yearPillar);
    _validatePillar(snapshot.monthPillar);
    _validatePillar(snapshot.dayPillar);
    if (snapshot.hourPillar != null) _validatePillar(snapshot.hourPillar!);
    final ranks = snapshot.warnings.map(_warningRank).toList(growable: false);
    if (snapshot.warnings.toSet().length != snapshot.warnings.length) {
      throw const SajuSnapshotValidationException(
        'Snapshot warnings contain duplicates.',
      );
    }
    for (var index = 1; index < ranks.length; index += 1) {
      if (ranks[index - 1] > ranks[index]) {
        throw const SajuSnapshotValidationException(
          'Snapshot warnings are not in canonical order.',
        );
      }
    }
  }

  bool _validLunarDate(KoreanLunarDate date) =>
      date.year >= 1 &&
      date.month >= 1 &&
      date.month <= 12 &&
      date.day >= 1 &&
      date.day <= 30;

  void _validatePillar(SexagenaryEntry pillar) {
    if (pillar.cycleIndex < 0 || pillar.cycleIndex > 59) {
      throw const SajuSnapshotValidationException('Pillar index is invalid.');
    }
    final canonical = SexagenaryRegistry.byIndex(pillar.cycleIndex);
    if (pillar.canonicalId != canonical.canonicalId ||
        pillar.stemIndex != canonical.stemIndex ||
        pillar.branchIndex != canonical.branchIndex ||
        pillar.hanja != canonical.hanja ||
        pillar.koreanLabel != canonical.koreanLabel) {
      throw const SajuSnapshotValidationException(
        'Pillar identity does not match the canonical registry.',
      );
    }
  }

  int _warningRank(SajuWarningCode warning) => switch (warning) {
    SajuWarningCode.minuteLevelSolarTermCompatibility => 0,
    SajuWarningCode.observedSeoulLongitudeCalibration => 1,
    SajuWarningCode.dayRolloverPolicyPendingCapture => 2,
    SajuWarningCode.hourUnknown => 3,
  };

  List<SajuWarningCode> _decodeWarnings(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! List) {
      throw const SajuSnapshotValidationException(
        'Snapshot warning payload is not a JSON array.',
      );
    }
    try {
      return List<SajuWarningCode>.unmodifiable(
        decoded.map((value) => SajuWarningCode.values.byName(value as String)),
      );
    } catch (_) {
      throw const SajuSnapshotValidationException(
        'Snapshot warning payload contains an unknown value.',
      );
    }
  }

  SexagenaryEntry _pillar(
    String id,
    int cycle,
    int stem,
    int branch,
    String hanja,
    String korean,
  ) => SexagenaryEntry(
    canonicalId: id,
    cycleIndex: cycle,
    stemIndex: stem,
    branchIndex: branch,
    hanja: hanja,
    koreanLabel: korean,
  );

  SajuCalendarType _calendarType(String value) =>
      SajuCalendarType.values.byName(value);
  SajuGender _gender(String value) => SajuGender.values.byName(value);

  SajuLocalDate _parseSolarDate(String value) {
    final parts = value.split('-');
    final date = SajuLocalDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    if (!date.isValid) {
      throw const SajuSnapshotValidationException('Stored solar date is invalid.');
    }
    return date;
  }

  KoreanLunarDate _parseLunarDate(
    String value, {
    required bool isLeapMonth,
  }) {
    final parts = value.split('-');
    final result = KoreanLunarDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
      isLeapMonth: isLeapMonth,
    );
    if (!_validLunarDate(result)) {
      throw const SajuSnapshotValidationException(
        'Stored lunar date is invalid.',
      );
    }
    return result;
  }

  SajuLocalTime _parseLocalTime(String value) {
    final parts = value.split(':');
    final seconds = parts[2].split('.');
    final microseconds = seconds.length == 1
        ? 0
        : int.parse(seconds[1].padRight(6, '0'));
    final result = SajuLocalTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      second: int.parse(seconds[0]),
      microsecond: microseconds,
    );
    if (!result.isValid) {
      throw const SajuSnapshotValidationException('Stored local time is invalid.');
    }
    return result;
  }

  String _digest(String source) {
    final accumulator = _digests.start();
    accumulator.add(utf8.encode(source));
    return accumulator.close();
  }
}
