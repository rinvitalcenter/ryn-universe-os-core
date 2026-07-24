import '../../features/people/data/persistence/drift_person_core_repositories.dart';
import '../../features/people/data/persistence/drift_person_group_repository.dart';
import '../../features/people/domain/person_core_repositories.dart';
import '../../features/tarot/data/persistence/drift_tarot_reading_repository.dart';
import '../../features/tarot/data/persistence/tarot_reading_repository.dart';
import '../persistence/app_database.dart';

/// One application-runtime composition over one open [RynAppDatabase].
///
/// Feature controllers receive repositories from this seam and must not open a
/// second SQLite connection for the same runtime profile.
final class RynRuntimeServices {
  RynRuntimeServices(this.database)
    : tarotReadings = DriftTarotReadingRepository(database),
      people = DriftPersonRepository(database),
      personRoles = DriftPersonRoleRepository(database),
      personGroups = DriftPersonGroupRepository(database),
      personRelationships = DriftPersonRelationshipRepository(database),
      personBirthProfiles = DriftPersonBirthProfileRepository(database),
      encounters = DriftEncounterRepository(database),
      encounterNotes = DriftEncounterNoteRepository(database);

  final RynAppDatabase database;
  final TarotReadingRepository tarotReadings;
  final PersonRepository people;
  final PersonRoleRepository personRoles;
  final PersonGroupRepository personGroups;
  final PersonRelationshipRepository personRelationships;
  final PersonBirthProfileRepository personBirthProfiles;
  final EncounterRepository encounters;
  final EncounterNoteRepository encounterNotes;
}
