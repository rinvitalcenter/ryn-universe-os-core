import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'database_paths.dart';

/// Creates the low-level Drift query executor for the future local runtime DB.
///
/// This setup slice intentionally opens only the database connection boundary.
/// It does not define tables, DAOs, repositories, CRUD operations, migrations,
/// backup/export/restore behavior, secure storage, or UI/Riverpod wiring.
Future<QueryExecutor> openRynRuntimeDatabaseConnection({
  String databaseFileName = defaultRynDatabaseFileName,
}) async {
  final runtimeDirectory = await ensureRuntimeDatabaseDirectory();
  final databaseFile = File(
    '${runtimeDirectory.path}${Platform.pathSeparator}$databaseFileName',
  );

  return NativeDatabase.createInBackground(databaseFile);
}
