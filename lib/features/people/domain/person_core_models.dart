const _unset = Object();

abstract final class PersonStatuses {
  static const active = 'active';
  static const inactive = 'inactive';
  static const values = {active, inactive};
}

abstract final class PersonRoleTypes {
  static const self = 'self';
  static const family = 'family';
  static const friend = 'friend';
  static const studyMember = 'studyMember';
  static const client = 'client';
  static const student = 'student';
  static const instructor = 'instructor';
  static const practiceParticipant = 'practiceParticipant';
  static const other = 'other';
  static const values = {
    self,
    family,
    friend,
    studyMember,
    client,
    student,
    instructor,
    practiceParticipant,
    other,
  };
}

abstract final class BirthPrecisions {
  static const exact = 'exact';
  static const approximate = 'approximate';
  static const unknown = 'unknown';
  static const values = {exact, approximate, unknown};
}

abstract final class BirthCalendarSystems {
  static const solar = 'solar';
  static const lunar = 'lunar';
  static const unknown = 'unknown';
  static const values = {solar, lunar, unknown};
}

abstract final class BirthVerificationStates {
  static const unverified = 'unverified';
  static const confirmed = 'confirmed';
  static const disputed = 'disputed';
  static const values = {unverified, confirmed, disputed};
}

abstract final class EncounterPrecisions {
  static const exact = 'exact';
  static const approximate = 'approximate';
  static const dateOnly = 'dateOnly';
  static const values = {exact, approximate, dateOnly};
}

abstract final class EncounterTypes {
  static const inPersonCounseling = 'inPersonCounseling';
  static const onlineCounseling = 'onlineCounseling';
  static const phoneCall = 'phoneCall';
  static const studyMeeting = 'studyMeeting';
  static const practiceInstruction = 'practiceInstruction';
  static const followUpReview = 'followUpReview';
  static const selfReview = 'selfReview';
  static const other = 'other';
  static const values = {
    inPersonCounseling,
    onlineCounseling,
    phoneCall,
    studyMeeting,
    practiceInstruction,
    followUpReview,
    selfReview,
    other,
  };
}

abstract final class EncounterStatuses {
  static const completed = 'completed';
  static const voided = 'voided';
  static const values = {completed, voided};
}

abstract final class EncounterNoteTypes {
  static const reportedFact = 'reportedFact';
  static const ownerObservation = 'ownerObservation';
  static const toolInterpretation = 'toolInterpretation';
  static const workingHypothesis = 'workingHypothesis';
  static const agreedAction = 'agreedAction';
  static const privateReflection = 'privateReflection';
  static const values = {
    reportedFact,
    ownerObservation,
    toolInterpretation,
    workingHypothesis,
    agreedAction,
    privateReflection,
  };
}

final class Person {
  const Person({
    required this.id,
    required this.displayName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.relationshipSummary,
    this.firstMetOn,
    this.archivedAt,
  });
  final String id;
  final String displayName;
  final String status;
  final String? relationshipSummary;
  final DateTime? firstMetOn;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Person copyWith({
    String? id,
    String? displayName,
    String? status,
    Object? relationshipSummary = _unset,
    Object? firstMetOn = _unset,
    Object? archivedAt = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Person(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    status: status ?? this.status,
    relationshipSummary: identical(relationshipSummary, _unset)
        ? this.relationshipSummary
        : relationshipSummary as String?,
    firstMetOn: identical(firstMetOn, _unset)
        ? this.firstMetOn
        : firstMetOn as DateTime?,
    archivedAt: identical(archivedAt, _unset)
        ? this.archivedAt
        : archivedAt as DateTime?,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

final class PersonRole {
  const PersonRole({
    required this.id,
    required this.personId,
    required this.roleType,
    required this.effectiveFrom,
    required this.createdAt,
    required this.updatedAt,
    this.effectiveTo,
    this.note,
  });
  final String id;
  final String personId;
  final String roleType;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonRole copyWith({
    String? id,
    String? personId,
    String? roleType,
    DateTime? effectiveFrom,
    Object? effectiveTo = _unset,
    Object? note = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PersonRole(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    roleType: roleType ?? this.roleType,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    effectiveTo: identical(effectiveTo, _unset)
        ? this.effectiveTo
        : effectiveTo as DateTime?,
    note: identical(note, _unset) ? this.note : note as String?,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

String normalizePersonGroupName(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

final class PersonGroup {
  const PersonGroup({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String name;
  final String normalizedName;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonGroup copyWith({
    String? id,
    String? name,
    String? normalizedName,
    Object? archivedAt = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PersonGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    archivedAt: identical(archivedAt, _unset)
        ? this.archivedAt
        : archivedAt as DateTime?,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

final class PersonGroupMembership {
  const PersonGroupMembership({
    required this.groupId,
    required this.personId,
    required this.createdAt,
  });

  final String groupId;
  final String personId;
  final DateTime createdAt;
}

final class PersonRelationship {
  const PersonRelationship({
    required this.id,
    required this.fromPersonId,
    required this.toPersonId,
    required this.relationshipType,
    required this.effectiveFrom,
    required this.createdAt,
    required this.updatedAt,
    this.effectiveTo,
    this.note,
  });
  final String id;
  final String fromPersonId;
  final String toPersonId;
  final String relationshipType;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonRelationship copyWith({
    String? id,
    String? fromPersonId,
    String? toPersonId,
    String? relationshipType,
    DateTime? effectiveFrom,
    Object? effectiveTo = _unset,
    Object? note = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PersonRelationship(
    id: id ?? this.id,
    fromPersonId: fromPersonId ?? this.fromPersonId,
    toPersonId: toPersonId ?? this.toPersonId,
    relationshipType: relationshipType ?? this.relationshipType,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    effectiveTo: identical(effectiveTo, _unset)
        ? this.effectiveTo
        : effectiveTo as DateTime?,
    note: identical(note, _unset) ? this.note : note as String?,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

final class PersonBirthProfile {
  const PersonBirthProfile({
    required this.id,
    required this.personId,
    required this.revisionNumber,
    required this.birthDatePrecision,
    required this.birthTimePrecision,
    required this.calendarSystem,
    required this.verificationState,
    required this.createdAt,
    this.birthDate,
    this.birthTime,
    this.birthplaceLabel,
    this.timeZoneId,
    this.utcOffsetMinutesAtBirth,
    this.isLeapMonth,
    this.sourceNote,
    this.supersedesBirthProfileId,
    this.supersededAt,
  });
  final String id;
  final String personId;
  final int revisionNumber;
  final String? birthDate;
  final String birthDatePrecision;
  final String? birthTime;
  final String birthTimePrecision;
  final String? birthplaceLabel;
  final String? timeZoneId;
  final int? utcOffsetMinutesAtBirth;
  final String calendarSystem;
  final bool? isLeapMonth;
  final String? sourceNote;
  final String verificationState;
  final String? supersedesBirthProfileId;
  final DateTime? supersededAt;
  final DateTime createdAt;

  PersonBirthProfile copyWith({
    String? id,
    String? personId,
    int? revisionNumber,
    Object? birthDate = _unset,
    String? birthDatePrecision,
    Object? birthTime = _unset,
    String? birthTimePrecision,
    Object? birthplaceLabel = _unset,
    Object? timeZoneId = _unset,
    Object? utcOffsetMinutesAtBirth = _unset,
    String? calendarSystem,
    Object? isLeapMonth = _unset,
    Object? sourceNote = _unset,
    String? verificationState,
    Object? supersedesBirthProfileId = _unset,
    Object? supersededAt = _unset,
    DateTime? createdAt,
  }) => PersonBirthProfile(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    revisionNumber: revisionNumber ?? this.revisionNumber,
    birthDate: identical(birthDate, _unset)
        ? this.birthDate
        : birthDate as String?,
    birthDatePrecision: birthDatePrecision ?? this.birthDatePrecision,
    birthTime: identical(birthTime, _unset)
        ? this.birthTime
        : birthTime as String?,
    birthTimePrecision: birthTimePrecision ?? this.birthTimePrecision,
    birthplaceLabel: identical(birthplaceLabel, _unset)
        ? this.birthplaceLabel
        : birthplaceLabel as String?,
    timeZoneId: identical(timeZoneId, _unset)
        ? this.timeZoneId
        : timeZoneId as String?,
    utcOffsetMinutesAtBirth: identical(utcOffsetMinutesAtBirth, _unset)
        ? this.utcOffsetMinutesAtBirth
        : utcOffsetMinutesAtBirth as int?,
    calendarSystem: calendarSystem ?? this.calendarSystem,
    isLeapMonth: identical(isLeapMonth, _unset)
        ? this.isLeapMonth
        : isLeapMonth as bool?,
    sourceNote: identical(sourceNote, _unset)
        ? this.sourceNote
        : sourceNote as String?,
    verificationState: verificationState ?? this.verificationState,
    supersedesBirthProfileId: identical(supersedesBirthProfileId, _unset)
        ? this.supersedesBirthProfileId
        : supersedesBirthProfileId as String?,
    supersededAt: identical(supersededAt, _unset)
        ? this.supersededAt
        : supersededAt as DateTime?,
    createdAt: createdAt ?? this.createdAt,
  );
}

final class Encounter {
  const Encounter({
    required this.id,
    required this.personId,
    required this.occurredAt,
    required this.occurredPrecision,
    required this.encounterType,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.summary,
    this.followUpAt,
    this.archivedAt,
  });
  final String id;
  final String personId;
  final DateTime occurredAt;
  final String occurredPrecision;
  final String encounterType;
  final String title;
  final String? summary;
  final String status;
  final DateTime? followUpAt;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Encounter copyWith({
    String? id,
    String? personId,
    DateTime? occurredAt,
    String? occurredPrecision,
    String? encounterType,
    String? title,
    Object? summary = _unset,
    String? status,
    Object? followUpAt = _unset,
    Object? archivedAt = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Encounter(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    occurredAt: occurredAt ?? this.occurredAt,
    occurredPrecision: occurredPrecision ?? this.occurredPrecision,
    encounterType: encounterType ?? this.encounterType,
    title: title ?? this.title,
    summary: identical(summary, _unset) ? this.summary : summary as String?,
    status: status ?? this.status,
    followUpAt: identical(followUpAt, _unset)
        ? this.followUpAt
        : followUpAt as DateTime?,
    archivedAt: identical(archivedAt, _unset)
        ? this.archivedAt
        : archivedAt as DateTime?,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

final class EncounterNote {
  const EncounterNote({
    required this.id,
    required this.encounterId,
    required this.noteType,
    required this.body,
    required this.recordedAt,
    required this.updatedAt,
    this.supersedesNoteId,
    this.supersededAt,
    this.redactedAt,
  });
  final String id;
  final String encounterId;
  final String noteType;
  final String body;
  final DateTime recordedAt;
  final DateTime updatedAt;
  final String? supersedesNoteId;
  final DateTime? supersededAt;
  final DateTime? redactedAt;

  EncounterNote copyWith({
    String? id,
    String? encounterId,
    String? noteType,
    String? body,
    DateTime? recordedAt,
    DateTime? updatedAt,
    Object? supersedesNoteId = _unset,
    Object? supersededAt = _unset,
    Object? redactedAt = _unset,
  }) => EncounterNote(
    id: id ?? this.id,
    encounterId: encounterId ?? this.encounterId,
    noteType: noteType ?? this.noteType,
    body: body ?? this.body,
    recordedAt: recordedAt ?? this.recordedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    supersedesNoteId: identical(supersedesNoteId, _unset)
        ? this.supersedesNoteId
        : supersedesNoteId as String?,
    supersededAt: identical(supersededAt, _unset)
        ? this.supersededAt
        : supersededAt as DateTime?,
    redactedAt: identical(redactedAt, _unset)
        ? this.redactedAt
        : redactedAt as DateTime?,
  );
}
