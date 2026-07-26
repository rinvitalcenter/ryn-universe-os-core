enum TarotReadingMode { self, person, practice }

enum TarotReadingSourceContext { home, people, reading, study }

final class TarotReadingContext {
  const TarotReadingContext._({
    required this.mode,
    required this.sourceContext,
    required this.sessionId,
    required this.personId,
  });

  factory TarotReadingContext.validated({
    required TarotReadingMode mode,
    required TarotReadingSourceContext sourceContext,
    required String sessionId,
    String? personId,
  }) {
    final validSessionId = _requiredIdentifier(sessionId, 'sessionId');
    final validPersonId = switch (mode) {
      TarotReadingMode.person => _requiredIdentifier(personId, 'personId'),
      TarotReadingMode.self || TarotReadingMode.practice =>
        personId == null
            ? null
            : throw ArgumentError.value(
                personId,
                'personId',
                'must be null for ${mode.name} readings',
              ),
    };

    return TarotReadingContext._(
      mode: mode,
      sourceContext: sourceContext,
      sessionId: validSessionId,
      personId: validPersonId,
    );
  }

  factory TarotReadingContext.self({
    required String sessionId,
    required TarotReadingSourceContext sourceContext,
  }) => TarotReadingContext.validated(
    mode: TarotReadingMode.self,
    sourceContext: sourceContext,
    sessionId: sessionId,
  );

  factory TarotReadingContext.person({
    required String sessionId,
    required TarotReadingSourceContext sourceContext,
    required String personId,
  }) => TarotReadingContext.validated(
    mode: TarotReadingMode.person,
    sourceContext: sourceContext,
    sessionId: sessionId,
    personId: personId,
  );

  factory TarotReadingContext.practice({
    required String sessionId,
    required TarotReadingSourceContext sourceContext,
  }) => TarotReadingContext.validated(
    mode: TarotReadingMode.practice,
    sourceContext: sourceContext,
    sessionId: sessionId,
  );

  factory TarotReadingContext.defaultReading({required String sessionId}) =>
      TarotReadingContext.self(
        sessionId: sessionId,
        sourceContext: TarotReadingSourceContext.reading,
      );

  final TarotReadingMode mode;
  final TarotReadingSourceContext sourceContext;
  final String sessionId;
  final String? personId;

  TarotReadingContext withSourceContext(
    TarotReadingSourceContext sourceContext,
  ) => TarotReadingContext.validated(
    mode: mode,
    sourceContext: sourceContext,
    sessionId: sessionId,
    personId: personId,
  );

  TarotReadingContext toSelf({TarotReadingSourceContext? sourceContext}) =>
      TarotReadingContext.self(
        sessionId: sessionId,
        sourceContext: sourceContext ?? this.sourceContext,
      );

  TarotReadingContext toPerson({
    required String personId,
    TarotReadingSourceContext? sourceContext,
  }) => TarotReadingContext.person(
    sessionId: sessionId,
    sourceContext: sourceContext ?? this.sourceContext,
    personId: personId,
  );

  TarotReadingContext toPractice({TarotReadingSourceContext? sourceContext}) =>
      TarotReadingContext.practice(
        sessionId: sessionId,
        sourceContext: sourceContext ?? this.sourceContext,
      );
}

String _requiredIdentifier(String? value, String fieldName) {
  if (value == null) {
    throw ArgumentError.notNull(fieldName);
  }
  if (value.isEmpty || value.trim().isEmpty) {
    throw ArgumentError.value(value, fieldName, 'must not be empty');
  }
  if (value != value.trim()) {
    throw ArgumentError.value(
      value,
      fieldName,
      'must not contain surrounding whitespace',
    );
  }
  return value;
}
