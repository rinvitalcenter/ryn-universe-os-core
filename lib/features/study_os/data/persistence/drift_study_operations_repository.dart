import 'package:drift/drift.dart';

import '../../../../core/persistence/app_database.dart';
import '../../../../core/repositories/repository_result.dart';
import '../../domain/study_operations_models.dart';
import '../../domain/study_operations_repository.dart';

final class DriftStudyOperationsRepository implements StudyOperationsRepository {
  DriftStudyOperationsRepository(this.database);

  final RynAppDatabase database;

  @override
  Stream<List<StudySessionSummary>> watchSessions() {
    return database
        .customSelect(
          '''SELECT s.*,
            GROUP_CONCAT(DISTINCT p.person_id) AS participant_ids,
            GROUP_CONCAT(DISTINCT p.attendance_status) AS attendance_states,
            COUNT(DISTINCT sm.material_id) AS material_count
          FROM study_sessions s
          LEFT JOIN study_session_participants p ON p.session_id = s.id
          LEFT JOIN study_session_materials sm ON sm.session_id = s.id
          GROUP BY s.id
          ORDER BY s.occurred_at_utc_us DESC, s.updated_at_utc_us DESC''',
          readsFrom: {
            database.studySessions,
            database.studySessionParticipants,
            database.studySessionMaterials,
          },
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => StudySessionSummary(
                  session: _sessionFromRow(row),
                  participantIds: _split(row.readNullable<String>('participant_ids')),
                  attendanceStates: _split(
                    row.readNullable<String>('attendance_states'),
                  ).map(_attendanceFromStorage).toSet(),
                  materialCount: row.read<int>('material_count'),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Stream<List<StudyMaterial>> watchMaterials() =>
      (database.select(database.studyMaterials)
            ..orderBy([(row) => OrderingTerm(expression: row.title)]))
          .watch()
          .map(
            (rows) => rows
                .map(
                  (row) => StudyMaterial(
                    id: row.id,
                    title: row.title,
                    type: _materialTypeFromStorage(row.type),
                    url: row.url,
                    storageNote: row.storageNote,
                    description: row.description,
                    createdAt: _date(row.createdAtUtcUs),
                    updatedAt: _date(row.updatedAtUtcUs),
                  ),
                )
                .toList(growable: false),
          );

  @override
  Future<RepositoryResult<StudySessionRecord>> loadSession(String sessionId) async {
    if (sessionId.trim().isEmpty) return _validation('회차를 찾을 수 없습니다.');
    try {
      final row = await database
          .customSelect(
            'SELECT * FROM study_sessions WHERE id = ?',
            variables: [Variable.withString(sessionId)],
            readsFrom: {database.studySessions},
          )
          .getSingleOrNull();
      if (row == null) {
        return RepositoryResult.failure(
          const RepositoryError(
            code: RepositoryErrorCode.notFound,
            safeMessage: '회차를 찾을 수 없습니다.',
          ),
        );
      }
      final participantRows = await database
          .customSelect(
            'SELECT * FROM study_session_participants WHERE session_id = ? '
            'ORDER BY created_at_utc_us, person_id',
            variables: [Variable.withString(sessionId)],
            readsFrom: {database.studySessionParticipants},
          )
          .get();
      final materialRows = await database
          .customSelect(
            'SELECT material_id FROM study_session_materials WHERE session_id = ? '
            'ORDER BY created_at_utc_us, material_id',
            variables: [Variable.withString(sessionId)],
            readsFrom: {database.studySessionMaterials},
          )
          .get();
      return RepositoryResult.success(
        StudySessionRecord(
          session: _sessionFromRow(row),
          participants: participantRows
              .map(
                (item) => StudySessionParticipant(
                  personId: item.read<String>('person_id'),
                  attendance: _attendanceFromStorage(
                    item.read<String>('attendance_status'),
                  ),
                  note: item.readNullable<String>('note'),
                  learningNote: item.readNullable<String>('learning_note'),
                ),
              )
              .toList(growable: false),
          materialIds: materialRows
              .map((item) => item.read<String>('material_id'))
              .toList(growable: false),
        ),
      );
    } on Object {
      return _persistenceFailure();
    }
  }

  @override
  Future<RepositoryResult<StudyMaterial>> saveMaterial(StudyMaterial material) async {
    if (material.id.trim().isEmpty || material.title.trim().isEmpty) {
      return _validation('자료 제목을 입력해 주세요.');
    }
    try {
      await database.customStatement(
        '''INSERT INTO study_materials
          (id, title, type, url, storage_note, description,
           created_at_utc_us, updated_at_utc_us)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET
            title = excluded.title,
            type = excluded.type,
            url = excluded.url,
            storage_note = excluded.storage_note,
            description = excluded.description,
            updated_at_utc_us = excluded.updated_at_utc_us''',
        [
          material.id.trim(),
          material.title.trim(),
          _materialTypeToStorage(material.type),
          _clean(material.url),
          _clean(material.storageNote),
          _clean(material.description),
          material.createdAt.toUtc().microsecondsSinceEpoch,
          material.updatedAt.toUtc().microsecondsSinceEpoch,
        ],
      );
      return RepositoryResult.success(material);
    } on Object {
      return _persistenceFailure(message: '자료를 저장하지 못했습니다.');
    }
  }

  @override
  Future<RepositoryResult<StudySessionRecord>> saveSession(
    StudySessionRecord record,
  ) async {
    final validation = _validateRecord(record);
    if (validation != null) return _validation(validation);
    try {
      await database.transaction(() async {
        final sessionId = record.session.id.trim();
        final existingParticipants = (await database.customSelect(
          'SELECT person_id FROM study_session_participants WHERE session_id = ?',
          variables: [Variable.withString(sessionId)],
          readsFrom: {database.studySessionParticipants},
        ).get()).map((row) => row.read<String>('person_id')).toSet();

        for (final participant in record.participants) {
          if (existingParticipants.contains(participant.personId)) continue;
          final person = await database.customSelect(
            'SELECT status, archived_at_utc_us FROM persons WHERE id = ?',
            variables: [Variable.withString(participant.personId)],
            readsFrom: {database.persons},
          ).getSingleOrNull();
          if (person == null ||
              person.read<String>('status') != 'active' ||
              person.readNullable<int>('archived_at_utc_us') != null) {
            throw const _StudyWriteBlocked('archived_or_inactive_person');
          }
        }

        for (final materialId in record.materialIds) {
          final material = await database.customSelect(
            'SELECT id FROM study_materials WHERE id = ?',
            variables: [Variable.withString(materialId)],
            readsFrom: {database.studyMaterials},
          ).getSingleOrNull();
          if (material == null) {
            throw const _StudyWriteBlocked('missing_material');
          }
        }

        final session = record.session;
        await database.customStatement(
          '''INSERT INTO study_sessions
            (id, title, occurred_at_utc_us, timezone_offset_minutes, location,
             track, status, summary, operation_notes, learning_goal,
             covered_content, progress_status, next_steps,
             created_at_utc_us, updated_at_utc_us)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
              title = excluded.title,
              occurred_at_utc_us = excluded.occurred_at_utc_us,
              timezone_offset_minutes = excluded.timezone_offset_minutes,
              location = excluded.location,
              track = excluded.track,
              status = excluded.status,
              summary = excluded.summary,
              operation_notes = excluded.operation_notes,
              learning_goal = excluded.learning_goal,
              covered_content = excluded.covered_content,
              progress_status = excluded.progress_status,
              next_steps = excluded.next_steps,
              updated_at_utc_us = excluded.updated_at_utc_us''',
          [
            sessionId,
            session.title.trim(),
            session.occurredAt.toUtc().microsecondsSinceEpoch,
            session.timezoneOffsetMinutes,
            session.location.trim(),
            session.track.name,
            session.status.name,
            _clean(session.summary),
            _clean(session.operationNotes),
            _clean(session.learningGoal),
            _clean(session.coveredContent),
            _progressToStorage(session.progress),
            _clean(session.nextSteps),
            session.createdAt.toUtc().microsecondsSinceEpoch,
            session.updatedAt.toUtc().microsecondsSinceEpoch,
          ],
        );

        await database.customStatement(
          'DELETE FROM study_session_participants WHERE session_id = ?',
          [sessionId],
        );
        await database.customStatement(
          'DELETE FROM study_session_materials WHERE session_id = ?',
          [sessionId],
        );
        final nowUs = session.updatedAt.toUtc().microsecondsSinceEpoch;
        for (final participant in record.participants) {
          await database.customStatement(
            '''INSERT INTO study_session_participants
              (session_id, person_id, attendance_status, note, learning_note,
               created_at_utc_us, updated_at_utc_us)
              VALUES (?, ?, ?, ?, ?, ?, ?)''',
            [
              sessionId,
              participant.personId,
              participant.attendance.name,
              _clean(participant.note),
              _clean(participant.learningNote),
              nowUs,
              nowUs,
            ],
          );
        }
        for (final materialId in record.materialIds) {
          await database.customStatement(
            '''INSERT INTO study_session_materials
              (session_id, material_id, created_at_utc_us) VALUES (?, ?, ?)''',
            [sessionId, materialId, nowUs],
          );
        }
      });
      return loadSession(record.session.id);
    } on _StudyWriteBlocked catch (error) {
      return _validation(
        error.code == 'archived_or_inactive_person'
            ? '활성 상태인 회원만 새 회차에 추가할 수 있습니다.'
            : '연결할 자료를 다시 확인해 주세요.',
      );
    } on Object {
      return _persistenceFailure(
        message: '회차를 저장하지 못했습니다. 입력 내용은 그대로 유지됩니다.',
      );
    }
  }

  String? _validateRecord(StudySessionRecord record) {
    final session = record.session;
    if (session.id.trim().isEmpty || session.title.trim().isEmpty) {
      return '회차 제목을 입력해 주세요.';
    }
    if (session.location.trim().isEmpty) return '장소를 입력해 주세요.';
    if (session.timezoneOffsetMinutes < -840 ||
        session.timezoneOffsetMinutes > 840) {
      return '시간대 정보를 확인해 주세요.';
    }
    final people = record.participants.map((item) => item.personId).toList();
    if (people.any((id) => id.trim().isEmpty) || people.toSet().length != people.length) {
      return '같은 회원을 한 회차에 두 번 연결할 수 없습니다.';
    }
    if (record.materialIds.any((id) => id.trim().isEmpty) ||
        record.materialIds.toSet().length != record.materialIds.length) {
      return '같은 자료를 한 회차에 두 번 연결할 수 없습니다.';
    }
    return null;
  }
}

StudySession _sessionFromRow(QueryRow row) => StudySession(
  id: row.read<String>('id'),
  title: row.read<String>('title'),
  occurredAt: _date(row.read<int>('occurred_at_utc_us')),
  timezoneOffsetMinutes: row.read<int>('timezone_offset_minutes'),
  location: row.read<String>('location'),
  track: StudyTrack.values.byName(row.read<String>('track')),
  status: StudySessionStatus.values.byName(row.read<String>('status')),
  summary: row.readNullable<String>('summary'),
  operationNotes: row.readNullable<String>('operation_notes'),
  learningGoal: row.readNullable<String>('learning_goal'),
  coveredContent: row.readNullable<String>('covered_content'),
  progress: _progressFromStorage(row.read<String>('progress_status')),
  nextSteps: row.readNullable<String>('next_steps'),
  createdAt: _date(row.read<int>('created_at_utc_us')),
  updatedAt: _date(row.read<int>('updated_at_utc_us')),
);

Set<String> _split(String? value) => value == null || value.isEmpty
    ? <String>{}
    : value.split(',').toSet();

DateTime _date(int microseconds) =>
    DateTime.fromMicrosecondsSinceEpoch(microseconds, isUtc: true);

String? _clean(String? value) {
  final clean = value?.trim();
  return clean == null || clean.isEmpty ? null : clean;
}

StudyAttendanceStatus _attendanceFromStorage(String value) =>
    StudyAttendanceStatus.values.byName(value);

String _progressToStorage(StudyProgressStatus value) => switch (value) {
  StudyProgressStatus.notStarted => 'not_started',
  StudyProgressStatus.inProgress => 'in_progress',
  StudyProgressStatus.completed => 'completed',
  StudyProgressStatus.deferred => 'deferred',
};

StudyProgressStatus _progressFromStorage(String value) => switch (value) {
  'not_started' => StudyProgressStatus.notStarted,
  'in_progress' => StudyProgressStatus.inProgress,
  'completed' => StudyProgressStatus.completed,
  'deferred' => StudyProgressStatus.deferred,
  _ => throw StateError('Unsupported Study progress value'),
};

String _materialTypeToStorage(StudyMaterialType value) => switch (value) {
  StudyMaterialType.handout => 'handout',
  StudyMaterialType.cardNews => 'card_news',
  StudyMaterialType.webPage => 'web_page',
  StudyMaterialType.video => 'video',
  StudyMaterialType.book => 'book',
  StudyMaterialType.practice => 'practice',
  StudyMaterialType.other => 'other',
};

StudyMaterialType _materialTypeFromStorage(String value) => switch (value) {
  'handout' => StudyMaterialType.handout,
  'card_news' => StudyMaterialType.cardNews,
  'web_page' => StudyMaterialType.webPage,
  'video' => StudyMaterialType.video,
  'book' => StudyMaterialType.book,
  'practice' => StudyMaterialType.practice,
  'other' => StudyMaterialType.other,
  _ => throw StateError('Unsupported Study material type'),
};

RepositoryResult<T> _validation<T>(String message) => RepositoryResult.failure(
  RepositoryError(
    code: RepositoryErrorCode.validationFailed,
    safeMessage: message,
  ),
);

RepositoryResult<T> _persistenceFailure<T>({
  String message = '스터디 기록을 불러오지 못했습니다.',
}) => RepositoryResult.failure(
  RepositoryError(
    code: RepositoryErrorCode.persistenceUnavailable,
    safeMessage: message,
  ),
);

final class _StudyWriteBlocked implements Exception {
  const _StudyWriteBlocked(this.code);
  final String code;
}
