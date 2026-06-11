import 'dart:async';

import '../obsidian_report_ref_repository.dart';
import '../repository_context.dart';
import '../repository_result.dart';
import '../redaction_state.dart';

/// In-memory fake for safe Obsidian report reference metadata.
///
/// This fake stores path/hash/doc-type metadata only and never reads or writes
/// Obsidian Markdown files.
final class FakeObsidianReportRefRepository
    implements ObsidianReportRefRepository {
  FakeObsidianReportRefRepository({List<ObsidianReportRefValue>? seed}) {
    for (final ref in seed ?? const <ObsidianReportRefValue>[]) {
      _refs[ref.id] = ref;
    }
  }

  final Map<String, ObsidianReportRefValue> _refs =
      <String, ObsidianReportRefValue>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Future<RepositoryResult<ObsidianReportRefValue>> linkReportRef({
    required String id,
    required String docType,
    required String vaultPath,
    required String? sha256,
    required RedactionState redactionState,
    required RepositoryContext context,
  }) async {
    if (vaultPath.trim().isEmpty) {
      return RepositoryResult.failure(
        const RepositoryError(
          code: RepositoryErrorCode.validationFailed,
          safeMessage: 'Obsidian vault path is required.',
        ),
      );
    }

    final ref = ObsidianReportRefValue(
      id: id,
      docType: docType,
      vaultPath: vaultPath,
      sha256: sha256,
      redactionState: redactionState,
      createdAt: context.occurredAt,
    );
    _refs[id] = ref;
    _changes.add(null);
    return RepositoryResult.success(ref);
  }

  @override
  Future<RepositoryResult<ObsidianReportRefValue?>> readReportRef(
    String id,
  ) async {
    return RepositoryResult.success(_refs[id]);
  }

  @override
  Stream<RepositoryResult<List<ObsidianReportRefValue>>> watchReportRefsByDocType(
    String docType,
  ) async* {
    yield RepositoryResult.success(_refsByDocType(docType));
    await for (final _ in _changes.stream) {
      yield RepositoryResult.success(_refsByDocType(docType));
    }
  }

  @override
  Future<RepositoryResult<ObsidianReportRefValue>> updateReportHash({
    required String id,
    required String? sha256,
    required RepositoryContext context,
  }) async {
    final existing = _refs[id];
    if (existing == null) {
      return RepositoryResult.failure(
        const RepositoryError(
          code: RepositoryErrorCode.notFound,
          safeMessage: 'Obsidian report reference was not found.',
        ),
      );
    }

    final updated = ObsidianReportRefValue(
      id: existing.id,
      docType: existing.docType,
      vaultPath: existing.vaultPath,
      sha256: sha256,
      redactionState: existing.redactionState,
      createdAt: existing.createdAt,
      updatedAt: context.occurredAt,
    );
    _refs[id] = updated;
    _changes.add(null);
    return RepositoryResult.success(updated);
  }

  Future<void> close() => _changes.close();

  List<ObsidianReportRefValue> _refsByDocType(String docType) {
    return _refs.values.where((ref) => ref.docType == docType).toList(
          growable: false,
        );
  }
}
