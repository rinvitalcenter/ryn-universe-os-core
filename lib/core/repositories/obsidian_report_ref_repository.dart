import 'repository_context.dart';
import 'repository_result.dart';
import 'redaction_state.dart';

/// Safe reference to a human-readable Obsidian governance document.
///
/// This DTO stores reference metadata only. It must not contain Markdown body
/// text, raw prompts, private logs, evidence binaries, or secrets.
final class ObsidianReportRefValue {
  const ObsidianReportRefValue({
    required this.id,
    required this.docType,
    required this.vaultPath,
    required this.redactionState,
    required this.createdAt,
    this.sha256,
    this.updatedAt,
  });

  final String id;
  final String docType;
  final String vaultPath;
  final String? sha256;
  final RedactionState redactionState;
  final DateTime createdAt;
  final DateTime? updatedAt;
}

/// Repository contract for safe Obsidian report references.
///
/// Implementations may store path/hash/doc-type metadata only. Obsidian document
/// bodies remain in the vault and must not be copied into the runtime database.
abstract interface class ObsidianReportRefRepository {
  Future<RepositoryResult<ObsidianReportRefValue>> linkReportRef({
    required String id,
    required String docType,
    required String vaultPath,
    required String? sha256,
    required RedactionState redactionState,
    required RepositoryContext context,
  });

  Future<RepositoryResult<ObsidianReportRefValue?>> readReportRef(String id);

  Stream<RepositoryResult<List<ObsidianReportRefValue>>> watchReportRefsByDocType(
    String docType,
  );

  Future<RepositoryResult<ObsidianReportRefValue>> updateReportHash({
    required String id,
    required String? sha256,
    required RepositoryContext context,
  });
}
