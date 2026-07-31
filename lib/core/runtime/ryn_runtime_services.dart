import 'dart:io';

import '../../features/people/data/persistence/drift_person_core_repositories.dart';
import '../../features/people/data/persistence/drift_person_group_repository.dart';
import '../../features/people/domain/person_core_repositories.dart';
import '../../features/qigong_blog/data/persistence/drift_qigong_blog_repository.dart';
import '../../features/qigong_blog/domain/qigong_blog_repository.dart';
import '../../features/qigong_blog/infrastructure/qigong_managed_media_store.dart';
import '../../features/saju/data/persistence/drift_saju_snapshot_repository.dart';
import '../../features/study_os/data/persistence/drift_study_operations_repository.dart';
import '../../features/study_os/domain/study_operations_repository.dart';
import '../../features/tarot/data/persistence/drift_tarot_reading_repository.dart';
import '../../features/tarot/data/persistence/tarot_reading_repository.dart';
import '../persistence/app_database.dart';

/// One application-runtime composition over one open [RynAppDatabase].
///
/// Feature controllers receive repositories from this seam and must not open a
/// second SQLite connection for the same runtime profile.
final class RynRuntimeServices {
  RynRuntimeServices(this.database, {String? profileRootPath})
    : tarotReadings = DriftTarotReadingRepository(database),
      people = DriftPersonRepository(database),
      personRoles = DriftPersonRoleRepository(database),
      personGroups = DriftPersonGroupRepository(database),
      personRelationships = DriftPersonRelationshipRepository(database),
      personBirthProfiles = DriftPersonBirthProfileRepository(database),
      encounters = DriftEncounterRepository(database),
      encounterNotes = DriftEncounterNoteRepository(database),
      qigongBlog = DriftQigongBlogRepository(database),
      qigongMedia = profileRootPath == null
          ? null
          : QigongManagedMediaStore(profileRoot: Directory(profileRootPath)),
      sajuSnapshots = DriftSajuSnapshotRepository(database),
      studyOperations = DriftStudyOperationsRepository(database);

  final RynAppDatabase database;
  final TarotReadingRepository tarotReadings;
  final PersonRepository people;
  final PersonRoleRepository personRoles;
  final PersonGroupRepository personGroups;
  final PersonRelationshipRepository personRelationships;
  final PersonBirthProfileRepository personBirthProfiles;
  final EncounterRepository encounters;
  final EncounterNoteRepository encounterNotes;
  final QigongBlogRepository qigongBlog;
  final QigongManagedMediaStore? qigongMedia;
  final DriftSajuSnapshotRepository sajuSnapshots;
  final StudyOperationsRepository studyOperations;
}
