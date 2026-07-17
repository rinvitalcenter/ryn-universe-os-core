import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum RynDataProfile { development, productionReserved }

enum RynRuntimeDataMode {
  standardDevelopment,
  tarotPersistenceQa,
  tarotBackupRecoveryQa,
}

abstract final class RynRuntimeDataModeContract {
  static const defineName = 'RYN_RUNTIME_DATA_MODE';
  static const approvedQaSelector = 'tarot_persistence_qa';
  static const backupRecoveryQaSelector = 'tarot_backup_recovery_qa';

  static RynRuntimeDataMode fromEnvironment() =>
      parseEnvironmentSelector(const String.fromEnvironment(defineName));

  static RynRuntimeDataMode parseEnvironmentSelector(String value) =>
      switch (value.trim()) {
        '' => RynRuntimeDataMode.standardDevelopment,
        approvedQaSelector => RynRuntimeDataMode.tarotPersistenceQa,
        _ => throw const RynDataProfileException(
          'Unsupported runtime data mode.',
        ),
      };

  static RynRuntimeDataMode parseHeadlessSelector(String value) => switch (value
      .trim()) {
    backupRecoveryQaSelector => RynRuntimeDataMode.tarotBackupRecoveryQa,
    _ => throw const RynDataProfileException('Unsupported headless data mode.'),
  };

  static RynRuntimeDataMode parseSelector(String value) => switch (value
      .trim()) {
    '' => RynRuntimeDataMode.standardDevelopment,
    approvedQaSelector => RynRuntimeDataMode.tarotPersistenceQa,
    backupRecoveryQaSelector => RynRuntimeDataMode.tarotBackupRecoveryQa,
    _ => throw const RynDataProfileException('Unsupported runtime data mode.'),
  };
}

abstract final class RynDataProfileContract {
  static const companyDirectoryName = 'RinVitalCenter';
  static const productDirectoryName = 'RynUniverseOS';
  static const developmentDatabaseFileName = 'ryn_universe_os_core_dev.sqlite';
  static const qaDatabaseFileName = 'ryn_universe_os_core_qa.sqlite';
  static const backupRecoveryQaDatabaseFileName =
      'ryn_universe_os_core_backup_recovery_qa.sqlite';
  static const productionDatabaseFileName = 'ryn_universe_os_core.sqlite';
  static const qaPurposeDirectoryName = 'core_tarot_self_reading_persistence1';
  static const backupRecoveryQaPurposeDirectoryName =
      'core_tarot_backup_recovery_v0_2';
  static const backupOutputDirectoryName = 'backup_output';
  static const recoverySafetyDirectoryName = 'recovery_safety';
  static const recoveryWorkDirectoryName = 'recovery_work';

  static RynDataProfile parse(String value) => switch (value.trim()) {
    'development' => RynDataProfile.development,
    'productionReserved' => RynDataProfile.productionReserved,
    _ => throw RynDataProfileException('Unsupported Ryn data profile.'),
  };
}

final class RynDataProfileException implements Exception {
  const RynDataProfileException(this.safeMessage);

  final String safeMessage;

  @override
  String toString() => 'RynDataProfileException: $safeMessage';
}

final class RynResolvedDatabasePath {
  const RynResolvedDatabasePath({
    required this.profile,
    required this.runtimeMode,
    required this.environment,
    required this.purpose,
    required this.relativeDatabasePath,
    required this.profileRootPath,
    required this.runtimeDirectoryPath,
    required this.databasePath,
  });

  final RynDataProfile profile;
  final RynRuntimeDataMode? runtimeMode;
  final String environment;
  final String purpose;
  final String relativeDatabasePath;
  final String profileRootPath;
  final String runtimeDirectoryPath;
  final String databasePath;

  bool get isStandardDevelopment =>
      runtimeMode == RynRuntimeDataMode.standardDevelopment;
  bool get isTaskSpecificQa =>
      runtimeMode == RynRuntimeDataMode.tarotPersistenceQa ||
      runtimeMode == RynRuntimeDataMode.tarotBackupRecoveryQa;
  bool get isBackupRecoveryQa =>
      runtimeMode == RynRuntimeDataMode.tarotBackupRecoveryQa;
  bool get isSyntheticOnly => isBackupRecoveryQa;

  String get backupOutputDirectoryPath =>
      p.join(profileRootPath, RynDataProfileContract.backupOutputDirectoryName);
  String get recoverySafetyDirectoryPath => p.join(
    profileRootPath,
    RynDataProfileContract.recoverySafetyDirectoryName,
  );
  String get recoveryWorkDirectoryPath =>
      p.join(profileRootPath, RynDataProfileContract.recoveryWorkDirectoryName);
}

typedef RynApplicationSupportRootProvider = Future<Directory> Function();

final class RynRuntimeDataPathContract {
  RynRuntimeDataPathContract({
    RynApplicationSupportRootProvider? applicationSupportRootProvider,
  }) : _fixedApplicationSupportRoot = null,
       _applicationSupportRootProvider =
           applicationSupportRootProvider ?? _defaultApplicationSupportRoot;

  RynRuntimeDataPathContract.forApplicationSupportRoot(Directory root)
    : _fixedApplicationSupportRoot = root,
      _applicationSupportRootProvider = null;

  final Directory? _fixedApplicationSupportRoot;
  final RynApplicationSupportRootProvider? _applicationSupportRootProvider;

  RynResolvedDatabasePath resolve(RynDataProfile profile) {
    final root = _fixedApplicationSupportRoot;
    if (root == null) {
      throw const RynDataProfileException(
        'Runtime application-support root must be resolved asynchronously.',
      );
    }
    return _resolveUnder(root, profile);
  }

  RynResolvedDatabasePath resolveMode(RynRuntimeDataMode mode) {
    final root = _fixedApplicationSupportRoot;
    if (root == null) {
      throw const RynDataProfileException(
        'Runtime application-support root must be resolved asynchronously.',
      );
    }
    return _resolveModeUnder(root, mode);
  }

  Future<RynResolvedDatabasePath> resolveRuntime(RynDataProfile profile) async {
    final root =
        _fixedApplicationSupportRoot ??
        await _applicationSupportRootProvider!();
    return _resolveUnder(root, profile);
  }

  Future<RynResolvedDatabasePath> resolveRuntimeMode(
    RynRuntimeDataMode mode,
  ) async {
    final root =
        _fixedApplicationSupportRoot ??
        await _applicationSupportRootProvider!();
    return _resolveModeUnder(root, mode);
  }

  RynResolvedDatabasePath requireOpenable(RynDataProfile profile) {
    if (profile != RynDataProfile.development) {
      throw const RynDataProfileException(
        'The production data profile is reserved and cannot be opened.',
      );
    }
    return resolve(profile);
  }

  Future<RynResolvedDatabasePath> requireRuntimeOpenable(
    RynDataProfile profile,
  ) async {
    if (profile != RynDataProfile.development) {
      throw const RynDataProfileException(
        'The production data profile is reserved and cannot be opened.',
      );
    }
    return resolveRuntime(profile);
  }

  RynResolvedDatabasePath requireOpenableMode(RynRuntimeDataMode mode) =>
      resolveMode(mode);

  Future<RynResolvedDatabasePath> requireRuntimeOpenableMode(
    RynRuntimeDataMode mode,
  ) => resolveRuntimeMode(mode);

  RynResolvedDatabasePath _resolveUnder(
    Directory applicationSupportRoot,
    RynDataProfile profile,
  ) {
    if (profile == RynDataProfile.development) {
      return _resolveModeUnder(
        applicationSupportRoot,
        RynRuntimeDataMode.standardDevelopment,
      );
    }
    final profileDirectory = switch (profile) {
      RynDataProfile.development => 'development',
      RynDataProfile.productionReserved => 'production',
    };
    final fileName = switch (profile) {
      RynDataProfile.development =>
        RynDataProfileContract.developmentDatabaseFileName,
      RynDataProfile.productionReserved =>
        RynDataProfileContract.productionDatabaseFileName,
    };
    final runtimeDirectoryPath = p.join(
      applicationSupportRoot.path,
      RynDataProfileContract.companyDirectoryName,
      RynDataProfileContract.productDirectoryName,
      profileDirectory,
      'runtime',
    );
    final relativeDatabasePath = p.join(profileDirectory, 'runtime', fileName);
    return RynResolvedDatabasePath(
      profile: profile,
      runtimeMode: null,
      environment: profileDirectory,
      purpose: 'reserved',
      relativeDatabasePath: relativeDatabasePath,
      profileRootPath: p.dirname(runtimeDirectoryPath),
      runtimeDirectoryPath: runtimeDirectoryPath,
      databasePath: p.join(runtimeDirectoryPath, fileName),
    );
  }

  RynResolvedDatabasePath _resolveModeUnder(
    Directory applicationSupportRoot,
    RynRuntimeDataMode mode,
  ) {
    final relativeRuntimeDirectory = switch (mode) {
      RynRuntimeDataMode.standardDevelopment => p.join(
        'development',
        'runtime',
      ),
      RynRuntimeDataMode.tarotPersistenceQa => p.join(
        'development',
        'qa',
        RynDataProfileContract.qaPurposeDirectoryName,
        'runtime',
      ),
      RynRuntimeDataMode.tarotBackupRecoveryQa => p.join(
        'development',
        'qa',
        RynDataProfileContract.backupRecoveryQaPurposeDirectoryName,
        'runtime',
      ),
    };
    final fileName = switch (mode) {
      RynRuntimeDataMode.standardDevelopment =>
        RynDataProfileContract.developmentDatabaseFileName,
      RynRuntimeDataMode.tarotPersistenceQa =>
        RynDataProfileContract.qaDatabaseFileName,
      RynRuntimeDataMode.tarotBackupRecoveryQa =>
        RynDataProfileContract.backupRecoveryQaDatabaseFileName,
    };
    final runtimeDirectoryPath = p.join(
      applicationSupportRoot.path,
      RynDataProfileContract.companyDirectoryName,
      RynDataProfileContract.productDirectoryName,
      relativeRuntimeDirectory,
    );
    return RynResolvedDatabasePath(
      profile: RynDataProfile.development,
      runtimeMode: mode,
      environment: 'development',
      purpose: switch (mode) {
        RynRuntimeDataMode.standardDevelopment => 'standard',
        RynRuntimeDataMode.tarotPersistenceQa =>
          RynDataProfileContract.qaPurposeDirectoryName,
        RynRuntimeDataMode.tarotBackupRecoveryQa =>
          RynDataProfileContract.backupRecoveryQaPurposeDirectoryName,
      },
      relativeDatabasePath: p.join(relativeRuntimeDirectory, fileName),
      profileRootPath: p.dirname(runtimeDirectoryPath),
      runtimeDirectoryPath: runtimeDirectoryPath,
      databasePath: p.join(runtimeDirectoryPath, fileName),
    );
  }
}

Future<Directory> _defaultApplicationSupportRoot() async {
  if (Platform.isWindows) {
    final appData = Platform.environment['APPDATA'];
    if (appData == null || appData.trim().isEmpty) {
      throw const RynDataProfileException(
        'Windows application-support root is unavailable.',
      );
    }
    return Directory(appData);
  }
  return getApplicationSupportDirectory();
}
