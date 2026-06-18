/// Static, non-runtime Study OS 2.0 MVP schema draft metadata.
///
/// This file intentionally does not define Drift database classes, tables,
/// migrations, schema versions, SQL, database connections, or runtime DB access.
class StudyOsSchemaDraft {
  const StudyOsSchemaDraft._();

  static const isRuntimeDatabase = false;
  static const definesTables = false;
  static const definesMigrations = false;
  static const definesSchemaVersion = false;
  static const opensOrWritesDatabase = false;

  static const entities = <StudyOsEntityDraft>[
    StudyOsEntityDraft(
      name: 'StudySession',
      responsibility: 'Represents one planned, active, completed, or archived study session.',
      fieldConcepts: <String>[
        'title',
        'date/time',
        'purpose',
        'status',
        'preparation state',
        'archive state',
      ],
    ),
    StudyOsEntityDraft(
      name: 'Member',
      responsibility: 'Represents a lightweight study participant reference.',
      fieldConcepts: <String>[
        'display name',
        'short note',
        'active/inactive state',
      ],
    ),
    StudyOsEntityDraft(
      name: 'AttendanceRecord',
      responsibility: 'Tracks readiness and attendance state for a member in a session.',
      fieldConcepts: <String>[
        'session reference',
        'member reference',
        'readiness state',
        'attendance state',
        'note',
      ],
    ),
    StudyOsEntityDraft(
      name: 'Material',
      responsibility: 'Represents a reusable study material reference.',
      fieldConcepts: <String>[
        'title',
        'type',
        'reference/link/path/note',
        'priority or requiredness hint',
      ],
    ),
    StudyOsEntityDraft(
      name: 'StudySessionMaterial',
      responsibility: 'Connects materials to sessions.',
      fieldConcepts: <String>[
        'session reference',
        'material reference',
        'session-specific note',
        'required/optional hint',
      ],
    ),
    StudyOsEntityDraft(
      name: 'JournalEntry',
      responsibility: 'Holds session notes, observations, and post-session journal text.',
      fieldConcepts: <String>[
        'session reference',
        'note text',
        'timing/context',
        'follow-up hint',
      ],
    ),
    StudyOsEntityDraft(
      name: 'ReportSummary',
      responsibility: 'Holds a simple manual summary or follow-up report for a session.',
      fieldConcepts: <String>[
        'session reference',
        'summary text',
        'completed items',
        'next actions',
      ],
    ),
    StudyOsEntityDraft(
      name: 'LocalSetting',
      responsibility: 'Holds local-first safety and app preference values needed for MVP.',
      fieldConcepts: <String>[
        'setting key/value concept',
        'local-first safety flag',
        'user preference hint',
      ],
    ),
  ];

  static const protectedLaterScope = <String>{
    'birth data',
    'counseling notes',
    'saju/tarot/astrology/human-design data',
    'health/personal notes',
  };

  static Set<String> get mvpEntityNames => {
        for (final entity in entities) entity.name,
      };
}

class StudyOsEntityDraft {
  const StudyOsEntityDraft({
    required this.name,
    required this.responsibility,
    required this.fieldConcepts,
  });

  final String name;
  final String responsibility;
  final List<String> fieldConcepts;

  bool get isConceptualOnly => true;
}
