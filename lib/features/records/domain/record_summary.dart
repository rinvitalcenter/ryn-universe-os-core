enum RecordModuleType { tarot, saju, qigong, study, encounter }

enum RecordType {
  tarotSelfReading,
  tarotManualReading,
  sajuChart,
  sajuInterpretation,
  qigongPractice,
  studySession,
  consultationNote,
  encounterNote,
}

enum RecordDisplayStatus { continuing, finished }

final class RecordKey {
  const RecordKey({required this.moduleType, required this.canonicalRecordId});

  final RecordModuleType moduleType;
  final String canonicalRecordId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordKey &&
          moduleType == other.moduleType &&
          canonicalRecordId == other.canonicalRecordId;

  @override
  int get hashCode => Object.hash(moduleType, canonicalRecordId);
}

final class RecordCapabilities {
  const RecordCapabilities({
    this.canPreview = false,
    this.canOpenFullDetail = false,
    this.canShowOnHome = false,
    this.canEdit = false,
  });

  final bool canPreview;
  final bool canOpenFullDetail;
  final bool canShowOnHome;
  final bool canEdit;
}

final class RecordSummary {
  RecordSummary({
    required this.key,
    required this.moduleType,
    required this.recordType,
    required this.occurredAt,
    required this.updatedAt,
    required this.title,
    required this.shortSummary,
    required this.status,
    required this.capabilities,
    this.personId,
    this.encounterId,
    this.studySessionId,
    this.searchTerms = const [],
  }) : assert(key.moduleType == moduleType);

  final RecordKey key;
  final RecordModuleType moduleType;
  final RecordType recordType;
  final DateTime occurredAt;
  final DateTime updatedAt;
  final String title;
  final String shortSummary;
  final String? personId;
  final String? encounterId;
  final String? studySessionId;
  final RecordDisplayStatus status;
  final RecordCapabilities capabilities;

  /// Adapter-derived search corpus. This is never displayed as a match
  /// fragment and is not persisted by Records Hub.
  final List<String> searchTerms;
}
