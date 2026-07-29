import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/study_operations_models.dart';
import '../domain/study_operations_repository.dart';

enum StudyEditorState { idle, editing, validating, saving, saved, failed }

final class StudySessionEditorController extends ChangeNotifier {
  StudySessionEditorController({
    required this.repository,
    required StudySessionRecord initialDraft,
  }) : _draft = initialDraft;

  final StudyOperationsRepository repository;
  StudySessionRecord _draft;
  StudyEditorState _state = StudyEditorState.editing;
  String? _errorMessage;
  Future<bool>? _inFlight;

  StudySessionRecord get draft => _draft;
  StudyEditorState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _state == StudyEditorState.saving;

  void updateDraft(StudySessionRecord value) {
    if (isSaving) return;
    _draft = value;
    _state = StudyEditorState.editing;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> save() {
    final active = _inFlight;
    if (active != null) return active;
    final operation = _saveOnce();
    _inFlight = operation;
    operation.whenComplete(() {
      if (identical(_inFlight, operation)) _inFlight = null;
    });
    return operation;
  }

  Future<bool> _saveOnce() async {
    _state = StudyEditorState.validating;
    _errorMessage = null;
    notifyListeners();
    final validation = _validate(_draft);
    if (validation != null) {
      _state = StudyEditorState.failed;
      _errorMessage = validation;
      notifyListeners();
      return false;
    }

    _state = StudyEditorState.saving;
    notifyListeners();
    final result = await repository.saveSession(_draft);
    if (result.isFailure) {
      _state = StudyEditorState.failed;
      _errorMessage = result.error!.safeMessage;
      notifyListeners();
      return false;
    }
    _draft = result.value!;
    _state = StudyEditorState.saved;
    notifyListeners();
    return true;
  }

  String? _validate(StudySessionRecord value) {
    final session = value.session;
    if (session.title.trim().isEmpty) return '제목을 입력해 주세요.';
    if (session.location.trim().isEmpty) return '장소를 입력해 주세요.';
    if (session.timezoneOffsetMinutes < -840 ||
        session.timezoneOffsetMinutes > 840) {
      return '시간대 정보를 확인해 주세요.';
    }
    final people = value.participants.map((item) => item.personId).toList();
    if (people.any((id) => id.trim().isEmpty) || people.toSet().length != people.length) {
      return '참여 회원을 다시 확인해 주세요.';
    }
    if (value.materialIds.toSet().length != value.materialIds.length) {
      return '연결 자료를 다시 확인해 주세요.';
    }
    return null;
  }
}
