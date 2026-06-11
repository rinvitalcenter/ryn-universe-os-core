import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Default SQLite database file name for the future Ryn Universe OS Core
/// runtime ledger.
///
/// This file contains path resolution only. It does not create schema, tables,
/// repositories, CRUD operations, backup/export/restore flows, or secret
/// storage wiring.
const String defaultRynDatabaseFileName = 'ryn_universe_os_core.sqlite';

/// App-managed runtime folder name under the OS application support directory.
const String rynRuntimeFolderName = 'runtime';

/// Resolves the future runtime database directory.
///
/// Expected platform locations are controlled by `path_provider`, for example:
/// - Windows: `%APPDATA%/.../runtime`
/// - macOS: `~/Library/Application Support/.../runtime`
///
/// The database must not live in the Obsidian vault or source tree.
Future<Directory> resolveRuntimeDatabaseDirectory() async {
  final appSupportDirectory = await getApplicationSupportDirectory();
  return Directory(p.join(appSupportDirectory.path, rynRuntimeFolderName));
}

/// Resolves the future runtime database file path.
///
/// This returns a path only. It does not open SQLite, create a database file, or
/// create schema.
Future<String> resolveRuntimeDatabasePath({
  String databaseFileName = defaultRynDatabaseFileName,
}) async {
  final runtimeDirectory = await resolveRuntimeDatabaseDirectory();
  return p.join(runtimeDirectory.path, databaseFileName);
}

/// Ensures the app-managed runtime database directory exists.
///
/// This is intentionally separate from [resolveRuntimeDatabasePath] so future
/// callers can decide exactly when filesystem side effects are allowed.
Future<Directory> ensureRuntimeDatabaseDirectory() async {
  final runtimeDirectory = await resolveRuntimeDatabaseDirectory();
  if (!runtimeDirectory.existsSync()) {
    await runtimeDirectory.create(recursive: true);
  }
  return runtimeDirectory;
}
