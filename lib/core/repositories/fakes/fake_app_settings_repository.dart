import 'dart:async';

import '../app_settings_repository.dart';
import '../repository_context.dart';
import '../repository_result.dart';
import '../redaction_state.dart';

/// In-memory fake for tests and future provider overrides.
///
/// This fake never opens a runtime database and must use synthetic, non-secret
/// data only.
final class FakeAppSettingsRepository implements AppSettingsRepository {
  FakeAppSettingsRepository({Map<String, AppSettingValue>? seed})
      : _settings = Map<String, AppSettingValue>.of(seed ?? const {});

  final Map<String, AppSettingValue> _settings;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Future<RepositoryResult<AppSettingValue?>> readSetting(String key) async {
    return RepositoryResult.success(_settings[key]);
  }

  @override
  Stream<RepositoryResult<AppSettingValue?>> watchSetting(String key) async* {
    yield RepositoryResult.success(_settings[key]);
    await for (final _ in _changes.stream) {
      yield RepositoryResult.success(_settings[key]);
    }
  }

  @override
  Future<RepositoryResult<void>> setNonSecretSetting({
    required String key,
    required String? value,
    required String valueType,
    required RedactionState redactionState,
    required RepositoryContext context,
  }) async {
    final validationError = _validateSafeSetting(key: key, value: value);
    if (validationError != null) {
      return RepositoryResult.failure(validationError);
    }

    _settings[key] = AppSettingValue(
      key: key,
      value: value,
      valueType: valueType,
      redactionState: redactionState,
      updatedAt: context.occurredAt,
    );
    _changes.add(null);
    return RepositoryResult.success(null);
  }

  @override
  Future<RepositoryResult<void>> removeNonSecretSetting({
    required String key,
    required RepositoryContext context,
  }) async {
    _settings.remove(key);
    _changes.add(null);
    return RepositoryResult.success(null);
  }

  Future<void> close() => _changes.close();

  RepositoryError? _validateSafeSetting({
    required String key,
    required String? value,
  }) {
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('secret') ||
        lowerKey.contains('token') ||
        lowerKey.contains('password') ||
        lowerKey.contains('api_key')) {
      return const RepositoryError(
        code: RepositoryErrorCode.sensitiveDataBlocked,
        safeMessage: 'Sensitive setting keys are not allowed here.',
      );
    }

    final lowerValue = value?.toLowerCase();
    if (lowerValue != null &&
        (lowerValue.contains('openrouter') ||
            lowerValue.contains('botfather') ||
            lowerValue.contains('telegram bot token'))) {
      return const RepositoryError(
        code: RepositoryErrorCode.sensitiveDataBlocked,
        safeMessage: 'Sensitive setting values are not allowed here.',
      );
    }

    return null;
  }
}
