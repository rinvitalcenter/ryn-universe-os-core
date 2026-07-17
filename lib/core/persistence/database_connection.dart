import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'runtime_data_profile.dart';

/// Creates the low-level Drift query executor for the future local runtime DB.
///
/// This setup slice intentionally opens only the database connection boundary.
/// It does not define tables, DAOs, repositories, CRUD operations, migrations,
/// backup/export/restore behavior, secure storage, or UI/Riverpod wiring.
Future<QueryExecutor> openRynRuntimeDatabaseConnection({
  required RynResolvedDatabasePath resolvedPath,
}) async {
  if (resolvedPath.profile != RynDataProfile.development) {
    throw const RynDataProfileException(
      'Only the development data profile may open a runtime database.',
    );
  }
  final runtimeDirectory = Directory(resolvedPath.runtimeDirectoryPath);
  if (!runtimeDirectory.existsSync()) {
    await runtimeDirectory.create(recursive: true);
  }
  final databaseFile = File(resolvedPath.databasePath);

  return NativeDatabase.createInBackground(databaseFile);
}
