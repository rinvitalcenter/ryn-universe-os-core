enum StudyTrack { tarot, saju, mixed }

enum StudySessionStatus { planned, completed, cancelled }

enum StudyAttendanceStatus { planned, attended, absent, late, cancelled }

enum StudyProgressStatus { notStarted, inProgress, completed, deferred }

enum StudyMaterialType {
  handout,
  cardNews,
  webPage,
  video,
  book,
  practice,
  other,
}

enum StudySortOrder { newest, oldest }

extension StudyTrackUi on StudyTrack {
  String get label => switch (this) {
    StudyTrack.tarot => '타로',
    StudyTrack.saju => '사주',
    StudyTrack.mixed => '통합',
  };
}

extension StudySessionStatusUi on StudySessionStatus {
  String get label => switch (this) {
    StudySessionStatus.planned => '예정',
    StudySessionStatus.completed => '완료',
    StudySessionStatus.cancelled => '취소',
  };
}

extension StudyAttendanceStatusUi on StudyAttendanceStatus {
  String get label => switch (this) {
    StudyAttendanceStatus.planned => '참석 예정',
    StudyAttendanceStatus.attended => '참석',
    StudyAttendanceStatus.absent => '결석',
    StudyAttendanceStatus.late => '지각',
    StudyAttendanceStatus.cancelled => '참여 취소',
  };
}

extension StudyProgressStatusUi on StudyProgressStatus {
  String get label => switch (this) {
    StudyProgressStatus.notStarted => '시작 전',
    StudyProgressStatus.inProgress => '진행 중',
    StudyProgressStatus.completed => '완료',
    StudyProgressStatus.deferred => '보류',
  };
}

extension StudyMaterialTypeUi on StudyMaterialType {
  String get label => switch (this) {
    StudyMaterialType.handout => '교안',
    StudyMaterialType.cardNews => '카드뉴스',
    StudyMaterialType.webPage => '웹페이지',
    StudyMaterialType.video => '영상 링크',
    StudyMaterialType.book => '도서',
    StudyMaterialType.practice => '실습 자료',
    StudyMaterialType.other => '기타',
  };
}

final class StudySession {
  const StudySession({
    required this.id,
    required this.title,
    required this.occurredAt,
    required this.timezoneOffsetMinutes,
    required this.location,
    required this.track,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.summary,
    this.operationNotes,
    this.learningGoal,
    this.coveredContent,
    this.progress = StudyProgressStatus.notStarted,
    this.nextSteps,
  });

  final String id;
  final String title;
  final DateTime occurredAt;
  final int timezoneOffsetMinutes;
  final String location;
  final StudyTrack track;
  final StudySessionStatus status;
  final String? summary;
  final String? operationNotes;
  final String? learningGoal;
  final String? coveredContent;
  final StudyProgressStatus progress;
  final String? nextSteps;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudySession copyWith({
    String? id,
    String? title,
    DateTime? occurredAt,
    int? timezoneOffsetMinutes,
    String? location,
    StudyTrack? track,
    StudySessionStatus? status,
    Object? summary = _unset,
    Object? operationNotes = _unset,
    Object? learningGoal = _unset,
    Object? coveredContent = _unset,
    StudyProgressStatus? progress,
    Object? nextSteps = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StudySession(
    id: id ?? this.id,
    title: title ?? this.title,
    occurredAt: occurredAt ?? this.occurredAt,
    timezoneOffsetMinutes: timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
    location: location ?? this.location,
    track: track ?? this.track,
    status: status ?? this.status,
    summary: identical(summary, _unset) ? this.summary : summary as String?,
    operationNotes: identical(operationNotes, _unset)
        ? this.operationNotes
        : operationNotes as String?,
    learningGoal: identical(learningGoal, _unset)
        ? this.learningGoal
        : learningGoal as String?,
    coveredContent: identical(coveredContent, _unset)
        ? this.coveredContent
        : coveredContent as String?,
    progress: progress ?? this.progress,
    nextSteps: identical(nextSteps, _unset) ? this.nextSteps : nextSteps as String?,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

final class StudySessionParticipant {
  const StudySessionParticipant({
    required this.personId,
    this.attendance = StudyAttendanceStatus.planned,
    this.note,
    this.learningNote,
  });

  final String personId;
  final StudyAttendanceStatus attendance;
  final String? note;
  final String? learningNote;

  StudySessionParticipant copyWith({
    String? personId,
    StudyAttendanceStatus? attendance,
    Object? note = _unset,
    Object? learningNote = _unset,
  }) => StudySessionParticipant(
    personId: personId ?? this.personId,
    attendance: attendance ?? this.attendance,
    note: identical(note, _unset) ? this.note : note as String?,
    learningNote: identical(learningNote, _unset)
        ? this.learningNote
        : learningNote as String?,
  );
}

final class StudyMaterial {
  const StudyMaterial({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.url,
    this.storageNote,
    this.description,
  });

  final String id;
  final String title;
  final StudyMaterialType type;
  final String? url;
  final String? storageNote;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyMaterial copyWith({
    String? id,
    String? title,
    StudyMaterialType? type,
    Object? url = _unset,
    Object? storageNote = _unset,
    Object? description = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StudyMaterial(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    url: identical(url, _unset) ? this.url : url as String?,
    storageNote: identical(storageNote, _unset)
        ? this.storageNote
        : storageNote as String?,
    description: identical(description, _unset)
        ? this.description
        : description as String?,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

final class StudySessionRecord {
  const StudySessionRecord({
    required this.session,
    this.participants = const <StudySessionParticipant>[],
    this.materialIds = const <String>[],
  });

  final StudySession session;
  final List<StudySessionParticipant> participants;
  final List<String> materialIds;

  StudySessionRecord copyWith({
    StudySession? session,
    List<StudySessionParticipant>? participants,
    List<String>? materialIds,
  }) => StudySessionRecord(
    session: session ?? this.session,
    participants: participants ?? this.participants,
    materialIds: materialIds ?? this.materialIds,
  );
}

final class StudySessionSummary {
  const StudySessionSummary({
    required this.session,
    required this.participantIds,
    required this.attendanceStates,
    required this.materialCount,
  });

  final StudySession session;
  final Set<String> participantIds;
  final Set<StudyAttendanceStatus> attendanceStates;
  final int materialCount;
}

final class StudySessionFilter {
  const StudySessionFilter({
    this.query = '',
    this.sortOrder = StudySortOrder.newest,
    this.track,
    this.status,
    this.personId,
    this.attendance,
    this.from,
    this.to,
  });

  final String query;
  final StudySortOrder sortOrder;
  final StudyTrack? track;
  final StudySessionStatus? status;
  final String? personId;
  final StudyAttendanceStatus? attendance;
  final DateTime? from;
  final DateTime? to;

  StudySessionFilter copyWith({
    String? query,
    StudySortOrder? sortOrder,
    Object? track = _unset,
    Object? status = _unset,
    Object? personId = _unset,
    Object? attendance = _unset,
    Object? from = _unset,
    Object? to = _unset,
  }) => StudySessionFilter(
    query: query ?? this.query,
    sortOrder: sortOrder ?? this.sortOrder,
    track: identical(track, _unset) ? this.track : track as StudyTrack?,
    status: identical(status, _unset)
        ? this.status
        : status as StudySessionStatus?,
    personId: identical(personId, _unset) ? this.personId : personId as String?,
    attendance: identical(attendance, _unset)
        ? this.attendance
        : attendance as StudyAttendanceStatus?,
    from: identical(from, _unset) ? this.from : from as DateTime?,
    to: identical(to, _unset) ? this.to : to as DateTime?,
  );
}

const _unset = Object();
