/// Redaction marker shared by repository contracts.
///
/// This is a lightweight value boundary only. It does not implement secure
/// storage, encryption, logging, export, or runtime persistence.
enum RedactionState {
  noneRequired('none_required'),
  redacted('redacted'),
  needsReview('needs_review'),
  blocked('blocked'),
  secretAliasOnly('secret_alias_only');

  const RedactionState(this.wireName);

  final String wireName;

  static RedactionState fromWireName(String value) {
    return RedactionState.values.firstWhere(
      (state) => state.wireName == value,
      orElse: () => RedactionState.needsReview,
    );
  }
}
