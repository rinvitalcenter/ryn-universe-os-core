import 'repository_context.dart';
import 'repository_result.dart';
import 'redaction_state.dart';

/// Non-secret app setting metadata.
///
/// This DTO mirrors the currently approved `app_settings` schema surface without
/// importing Drift generated classes or opening a database.
final class AppSettingValue {
  const AppSettingValue({
    required this.key,
    required this.value,
    required this.valueType,
    required this.redactionState,
    required this.updatedAt,
  });

  final String key;
  final String? value;
  final String valueType;
  final RedactionState redactionState;
  final DateTime updatedAt;
}

/// Repository contract for non-secret application settings.
///
/// Implementations must not store raw secrets, provider tokens, private payloads,
/// or raw prompts in app settings.
abstract interface class AppSettingsRepository {
  Future<RepositoryResult<AppSettingValue?>> readSetting(String key);

  Stream<RepositoryResult<AppSettingValue?>> watchSetting(String key);

  Future<RepositoryResult<void>> setNonSecretSetting({
    required String key,
    required String? value,
    required String valueType,
    required RedactionState redactionState,
    required RepositoryContext context,
  });

  Future<RepositoryResult<void>> removeNonSecretSetting({
    required String key,
    required RepositoryContext context,
  });
}
