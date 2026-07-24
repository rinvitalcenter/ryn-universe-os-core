import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../../core/persistence/app_database.dart';
import '../../../../core/repositories/repository_result.dart';
import '../../domain/person_core_models.dart';
import '../../domain/person_core_repositories.dart';

final class DriftPersonGroupRepository implements PersonGroupRepository {
  DriftPersonGroupRepository(this.database);

  final RynAppDatabase database;

  @override
  Stream<List<PersonGroup>> watchActiveGroups() =>
      _watchGroups(archived: false);

  @override
  Stream<List<PersonGroup>> watchArchivedGroups() =>
      _watchGroups(archived: true);

  Stream<List<PersonGroup>> _watchGroups({required bool archived}) {
    final query = database.select(database.personGroups)
      ..where(
        (table) => archived
            ? table.archivedAtUtcUs.isNotNull()
            : table.archivedAtUtcUs.isNull(),
      )
      ..orderBy([(table) => OrderingTerm(expression: table.normalizedName)]);
    return query.watch().map(
      (rows) => rows.map(_groupFromRow).toList(growable: false),
    );
  }

  @override
  Stream<List<PersonGroupMembership>> watchMembershipsForPerson(
    String personId,
  ) {
    final query = database.select(database.personGroupMemberships)
      ..where((table) => table.personId.equals(personId))
      ..orderBy([(table) => OrderingTerm(expression: table.createdAtUtcUs)]);
    return query.watch().map(
      (rows) => rows.map(_membershipFromRow).toList(growable: false),
    );
  }

  @override
  Stream<List<Person>> watchPeopleInGroup(String groupId) {
    final query =
        database.select(database.persons).join([
            innerJoin(
              database.personGroupMemberships,
              database.personGroupMemberships.personId.equalsExp(
                database.persons.id,
              ),
            ),
          ])
          ..where(database.personGroupMemberships.groupId.equals(groupId))
          ..orderBy([OrderingTerm(expression: database.persons.displayName)]);
    return query.watch().map(
      (rows) => rows
          .map((row) => _personFromRow(row.readTable(database.persons)))
          .toList(growable: false),
    );
  }

  @override
  Future<RepositoryResult<PersonGroup>> createGroup(PersonGroup group) async {
    final canonical = _canonicalGroup(group);
    if (!_validGroup(canonical) || canonical.archivedAt != null) {
      return _validation<PersonGroup>();
    }
    return _write(() async {
      await database
          .into(database.personGroups)
          .insert(
            PersonGroupsCompanion.insert(
              id: canonical.id,
              name: canonical.name,
              normalizedName: canonical.normalizedName,
              archivedAtUtcUs: const Value.absent(),
              createdAtUtcUs: _us(canonical.createdAt),
              updatedAtUtcUs: _us(canonical.updatedAt),
            ),
          );
      return canonical;
    });
  }

  @override
  Future<RepositoryResult<PersonGroup>> renameGroup(
    String id, {
    required String name,
    required DateTime updatedAt,
  }) async {
    final existing = await _getGroup(id);
    if (existing == null) return _notFound<PersonGroup>();
    final renamed = _canonicalGroup(
      existing.copyWith(
        name: name,
        normalizedName: normalizePersonGroupName(name),
        updatedAt: updatedAt,
      ),
    );
    if (!_validGroup(renamed)) return _validation<PersonGroup>();
    return _write(() async {
      final changed =
          await (database.update(
            database.personGroups,
          )..where((table) => table.id.equals(id))).write(
            PersonGroupsCompanion(
              name: Value(renamed.name),
              normalizedName: Value(renamed.normalizedName),
              updatedAtUtcUs: Value(_us(updatedAt)),
            ),
          );
      if (changed != 1) throw const _MissingRow();
      return renamed;
    });
  }

  @override
  Future<RepositoryResult<PersonGroup>> archiveGroup(
    String id, {
    required DateTime at,
  }) => _setArchived(id, archivedAt: at, updatedAt: at);

  @override
  Future<RepositoryResult<PersonGroup>> restoreGroup(
    String id, {
    required DateTime at,
  }) => _setArchived(id, archivedAt: null, updatedAt: at);

  Future<RepositoryResult<PersonGroup>> _setArchived(
    String id, {
    required DateTime? archivedAt,
    required DateTime updatedAt,
  }) async {
    final existing = await _getGroup(id);
    if (existing == null) return _notFound<PersonGroup>();
    final changed = existing.copyWith(
      archivedAt: archivedAt,
      updatedAt: updatedAt,
    );
    if (!_validGroup(changed)) return _validation<PersonGroup>();
    return _write(() async {
      final count =
          await (database.update(
            database.personGroups,
          )..where((table) => table.id.equals(id))).write(
            PersonGroupsCompanion(
              archivedAtUtcUs: Value(
                archivedAt == null ? null : _us(archivedAt),
              ),
              updatedAtUtcUs: Value(_us(updatedAt)),
            ),
          );
      if (count != 1) throw const _MissingRow();
      return changed;
    });
  }

  @override
  Future<RepositoryResult<PersonGroupMembership>> assignPerson({
    required String groupId,
    required String personId,
    required DateTime createdAt,
  }) {
    if (groupId.trim().isEmpty || personId.trim().isEmpty || !createdAt.isUtc) {
      return Future.value(_validation<PersonGroupMembership>());
    }
    return _write(
      () => database.transaction(() async {
        final group = await _getGroup(groupId);
        if (group == null) throw const _MissingRow();
        if (group.archivedAt != null) throw const _InvalidInput();
        final personExists =
            await (database.selectOnly(database.persons)
                  ..addColumns([database.persons.id])
                  ..where(database.persons.id.equals(personId)))
                .getSingleOrNull();
        if (personExists == null) throw const _MissingRow();

        await database
            .into(database.personGroupMemberships)
            .insert(
              PersonGroupMembershipsCompanion.insert(
                groupId: groupId,
                personId: personId,
                createdAtUtcUs: _us(createdAt),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        final row =
            await (database.select(database.personGroupMemberships)..where(
                  (table) =>
                      table.groupId.equals(groupId) &
                      table.personId.equals(personId),
                ))
                .getSingle();
        return _membershipFromRow(row);
      }),
    );
  }

  @override
  Future<RepositoryResult<bool>> removePerson({
    required String groupId,
    required String personId,
  }) => _write(() async {
    final count =
        await (database.delete(database.personGroupMemberships)..where(
              (table) =>
                  table.groupId.equals(groupId) &
                  table.personId.equals(personId),
            ))
            .go();
    return count == 1;
  });

  Future<PersonGroup?> _getGroup(String id) async {
    final row = await (database.select(
      database.personGroups,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _groupFromRow(row);
  }
}

PersonGroup _canonicalGroup(PersonGroup value) {
  final name = value.name.trim().replaceAll(RegExp(r'\s+'), ' ');
  return value.copyWith(
    name: name,
    normalizedName: normalizePersonGroupName(name),
  );
}

bool _validGroup(PersonGroup value) =>
    value.id.trim().isNotEmpty &&
    value.name.isNotEmpty &&
    value.name.runes.length <= 60 &&
    value.normalizedName.isNotEmpty &&
    value.normalizedName.runes.length <= 60 &&
    value.normalizedName == normalizePersonGroupName(value.name) &&
    value.createdAt.isUtc &&
    value.updatedAt.isUtc &&
    !value.updatedAt.isBefore(value.createdAt) &&
    (value.archivedAt == null ||
        (value.archivedAt!.isUtc &&
            !value.archivedAt!.isBefore(value.createdAt)));

PersonGroup _groupFromRow(PersonGroupRow row) => PersonGroup(
  id: row.id,
  name: row.name,
  normalizedName: row.normalizedName,
  archivedAt: _nullableDate(row.archivedAtUtcUs),
  createdAt: _date(row.createdAtUtcUs),
  updatedAt: _date(row.updatedAtUtcUs),
);

PersonGroupMembership _membershipFromRow(PersonGroupMembershipRow row) =>
    PersonGroupMembership(
      groupId: row.groupId,
      personId: row.personId,
      createdAt: _date(row.createdAtUtcUs),
    );

Person _personFromRow(PersonRow row) => Person(
  id: row.id,
  displayName: row.displayName,
  status: row.status,
  relationshipSummary: row.relationshipSummary,
  firstMetOn: _nullableDate(row.firstMetOnUtcUs),
  archivedAt: _nullableDate(row.archivedAtUtcUs),
  createdAt: _date(row.createdAtUtcUs),
  updatedAt: _date(row.updatedAtUtcUs),
);

int _us(DateTime value) => value.toUtc().microsecondsSinceEpoch;
DateTime _date(int value) =>
    DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
DateTime? _nullableDate(int? value) => value == null ? null : _date(value);

Future<RepositoryResult<T>> _write<T>(Future<T> Function() body) async {
  try {
    return RepositoryResult.success(await body());
  } on _MissingRow {
    return _notFound<T>();
  } on _InvalidInput {
    return _validation<T>();
  } on SqliteException catch (error) {
    final conflict =
        error.message.toLowerCase().contains('unique') ||
        error.extendedResultCode == 2067;
    return RepositoryResult.failure(
      RepositoryError(
        code: conflict
            ? RepositoryErrorCode.conflict
            : RepositoryErrorCode.persistenceUnavailable,
        safeMessage: conflict
            ? 'The group conflicts with existing data.'
            : 'The group could not be stored.',
      ),
    );
  } on Object {
    return RepositoryResult.failure(
      const RepositoryError(
        code: RepositoryErrorCode.persistenceUnavailable,
        safeMessage: 'The group could not be stored.',
      ),
    );
  }
}

RepositoryResult<T> _validation<T>() => RepositoryResult.failure(
  const RepositoryError(
    code: RepositoryErrorCode.validationFailed,
    safeMessage: 'The group input is invalid.',
  ),
);

RepositoryResult<T> _notFound<T>() => RepositoryResult.failure(
  const RepositoryError(
    code: RepositoryErrorCode.notFound,
    safeMessage: 'The group or person was not found.',
  ),
);

final class _MissingRow implements Exception {
  const _MissingRow();
}

final class _InvalidInput implements Exception {
  const _InvalidInput();
}
