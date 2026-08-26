/// Lesson prose for one language.
///
/// Interface chrome stays in the generated ARB localizations. Lesson bodies
/// are long-form translated content addressed by identifier, so they are kept
/// as one map per language: a translator edits a single readable file, and the
/// hub can prove both languages cover the whole catalog.
final class TheoryContent {
  const TheoryContent({required this.languageCode, required this.entries});

  final String languageCode;
  final Map<String, String> entries;

  /// The text for [textId], or the identifier itself when it is missing.
  ///
  /// A missing identifier is a content bug rather than a runtime failure, so
  /// the hub still renders and the localization test reports the gap.
  String text(String textId) => entries[textId] ?? textId;

  String? maybeText(String textId) => entries[textId];

  bool contains(String textId) => entries.containsKey(textId);
}
