import '../../../../core/repositories/repository_result.dart';
import 'person_core_models.dart';

abstract interface class PersonRepository {
  Future<RepositoryResult<Person>> createPerson(Person person);
  Future<RepositoryResult<Person>> getPerson(String id);
  Stream<List<Person>> watchPeople({bool includeArchived = false});
  Future<RepositoryResult<Person>> updatePerson(Person person);
  Future<RepositoryResult<Person>> archivePerson(
    String id, {
    required DateTime at,
  });
  Future<RepositoryResult<Person>> restorePerson(
    String id, {
    required DateTime at,
  });
  Future<RepositoryResult<Person?>> findActiveSelfPerson();
  Future<RepositoryResult<bool>> erasePerson(String id);
}

abstract interface class PersonRoleRepository {
  Future<RepositoryResult<PersonRole>> addRole(PersonRole role);
  Future<RepositoryResult<PersonRole>> closeRole(
    String id, {
    required DateTime effectiveTo,
    required DateTime updatedAt,
  });
  Stream<List<PersonRole>> watchRolesForPerson(String personId);
}

abstract interface class PersonRelationshipRepository {
  Future<RepositoryResult<PersonRelationship>> createRelationship(
    PersonRelationship relationship,
  );
  Future<RepositoryResult<PersonRelationship>> closeRelationship(
    String id, {
    required DateTime effectiveTo,
    required DateTime updatedAt,
  });
  Stream<List<PersonRelationship>> watchRelationshipsForPerson(String personId);
}

abstract interface class PersonBirthProfileRepository {
  Future<RepositoryResult<PersonBirthProfile>> createInitialProfile(
    PersonBirthProfile profile,
  );
  Future<RepositoryResult<PersonBirthProfile>> createRevision(
    PersonBirthProfile revision,
  );
  Future<RepositoryResult<PersonBirthProfile?>> getCurrentProfile(
    String personId,
  );
  Stream<List<PersonBirthProfile>> watchProfileHistory(String personId);
}

abstract interface class EncounterRepository {
  Future<RepositoryResult<Encounter>> createEncounter(Encounter encounter);
  Future<RepositoryResult<Encounter>> getEncounter(String id);
  Stream<List<Encounter>> watchEncountersForPerson(
    String personId, {
    bool includeArchived = false,
  });
  Future<RepositoryResult<Encounter>> updateEncounter(Encounter encounter);
  Future<RepositoryResult<Encounter>> archiveEncounter(
    String id, {
    required DateTime at,
  });
}

abstract interface class EncounterNoteRepository {
  Future<RepositoryResult<EncounterNote>> addNote(EncounterNote note);
  Future<RepositoryResult<EncounterNote>> correctTypo(
    String id, {
    required String body,
    required DateTime updatedAt,
  });
  Future<RepositoryResult<EncounterNote>> createRevision(
    EncounterNote revision,
  );
  Future<RepositoryResult<EncounterNote>> redactNote(
    String id, {
    required DateTime at,
  });
  Stream<List<EncounterNote>> watchNotesForEncounter(String encounterId);
}
