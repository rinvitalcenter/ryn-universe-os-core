class TarotInterpretationSessionDraft {
  const TarotInterpretationSessionDraft({
    required this.readingInstanceId,
    this.wholeImageObservation = '',
    this.flowInterpretation = '',
    this.coreMessage = '',
    this.smallAction = '',
  });

  final String readingInstanceId;
  final String wholeImageObservation;
  final String flowInterpretation;
  final String coreMessage;
  final String smallAction;

  bool get hasMeaningfulText =>
      wholeImageObservation.trim().isNotEmpty ||
      flowInterpretation.trim().isNotEmpty ||
      coreMessage.trim().isNotEmpty ||
      smallAction.trim().isNotEmpty;

  bool hasSameContentAs(TarotInterpretationSessionDraft other) =>
      readingInstanceId == other.readingInstanceId &&
      wholeImageObservation == other.wholeImageObservation &&
      flowInterpretation == other.flowInterpretation &&
      coreMessage == other.coreMessage &&
      smallAction == other.smallAction;

  TarotInterpretationSessionDraft copyWith({
    String? wholeImageObservation,
    String? flowInterpretation,
    String? coreMessage,
    String? smallAction,
  }) {
    return TarotInterpretationSessionDraft(
      readingInstanceId: readingInstanceId,
      wholeImageObservation:
          wholeImageObservation ?? this.wholeImageObservation,
      flowInterpretation: flowInterpretation ?? this.flowInterpretation,
      coreMessage: coreMessage ?? this.coreMessage,
      smallAction: smallAction ?? this.smallAction,
    );
  }
}
