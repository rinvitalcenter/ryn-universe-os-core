import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/repositories/repository_result.dart';
import 'package:ryn_universe_os_core/features/study_os/application/study_session_editor_controller.dart';
import 'package:ryn_universe_os_core/features/study_os/domain/study_operations_models.dart';
import 'package:ryn_universe_os_core/features/study_os/domain/study_operations_repository.dart';

void main() {
  final now = DateTime.utc(2026, 8, 1, 9);

  test('validation preserves draft and does not call repository', () async {
    final repository = _FakeStudyRepository();
    final controller = StudySessionEditorController(
      repository: repository,
      initialDraft: _record(title: '   ', now: now),
    );

    final result = await controller.save();

    expect(result, isFalse);
    expect(controller.state, StudyEditorState.failed);
    expect(controller.errorMessage, '제목을 입력해 주세요.');
    expect(controller.draft.session.title, '   ');
    expect(repository.saveCalls, 0);
  });

  test('rapid duplicate save shares one request and reaches saved state', () async {
    final repository = _FakeStudyRepository(delayed: true);
    final controller = StudySessionEditorController(
      repository: repository,
      initialDraft: _record(now: now),
    );

    final first = controller.save();
    final second = controller.save();
    expect(controller.state, StudyEditorState.saving);
    expect(repository.saveCalls, 1);

    repository.completeSuccess();
    expect(await first, isTrue);
    expect(await second, isTrue);
    expect(controller.state, StudyEditorState.saved);
    expect(repository.saveCalls, 1);
  });

  test('failed persistence keeps all entered values for retry', () async {
    final repository = _FakeStudyRepository(fail: true);
    final draft = _record(now: now).copyWith(
      participants: const [
        StudySessionParticipant(
          personId: 'person.synthetic',
          attendance: StudyAttendanceStatus.late,
          note: '조기 귀가 예정',
        ),
      ],
      materialIds: const ['material.synthetic'],
    );
    final controller = StudySessionEditorController(
      repository: repository,
      initialDraft: draft,
    );

    expect(await controller.save(), isFalse);
    expect(controller.state, StudyEditorState.failed);
    expect(controller.draft.participants.single.note, '조기 귀가 예정');
    expect(controller.draft.materialIds, ['material.synthetic']);
  });
}

StudySessionRecord _record({required DateTime now, String title = '합성 회차'}) =>
    StudySessionRecord(
      session: StudySession(
        id: 'session.synthetic',
        title: title,
        occurredAt: now.add(const Duration(days: 1)),
        timezoneOffsetMinutes: 540,
        location: '합성 공간',
        track: StudyTrack.mixed,
        status: StudySessionStatus.planned,
        summary: '운영 주제',
        operationNotes: '운영 메모',
        learningGoal: '학습 목표',
        coveredContent: '',
        progress: StudyProgressStatus.notStarted,
        nextSteps: '',
        createdAt: now,
        updatedAt: now,
      ),
    );

final class _FakeStudyRepository implements StudyOperationsRepository {
  _FakeStudyRepository({this.delayed = false, this.fail = false});

  final bool delayed;
  final bool fail;
  int saveCalls = 0;
  Completer<RepositoryResult<StudySessionRecord>>? _completer;

  void completeSuccess() => _completer?.complete(
    RepositoryResult.success(_record(now: DateTime.utc(2026, 8, 1, 9))),
  );

  @override
  Future<RepositoryResult<StudySessionRecord>> saveSession(
    StudySessionRecord record,
  ) {
    saveCalls += 1;
    if (delayed) {
      _completer = Completer<RepositoryResult<StudySessionRecord>>();
      return _completer!.future;
    }
    if (fail) {
      return Future.value(
        RepositoryResult.failure(
          const RepositoryError(
            code: RepositoryErrorCode.persistenceUnavailable,
            safeMessage: '저장하지 못했습니다. 입력 내용은 그대로 유지됩니다.',
          ),
        ),
      );
    }
    return Future.value(RepositoryResult.success(record));
  }

  @override
  Future<RepositoryResult<StudySessionRecord>> loadSession(String sessionId) =>
      throw UnimplementedError();

  @override
  Stream<List<StudySessionSummary>> watchSessions() => const Stream.empty();

  @override
  Stream<List<StudyMaterial>> watchMaterials() => const Stream.empty();

  @override
  Future<RepositoryResult<StudyMaterial>> saveMaterial(StudyMaterial material) =>
      throw UnimplementedError();
}
