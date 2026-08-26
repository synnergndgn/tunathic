/// The learning progression a lesson belongs to.
///
/// Every lesson has exactly one level, so the hub can present a beginner to
/// advanced path without tracking per-user skill.
enum TheoryLevel {
  beginner('beginner'),
  intermediate('intermediate'),
  advanced('advanced');

  const TheoryLevel(this.id);

  final String id;

  static TheoryLevel? fromId(String? id) {
    for (final level in values) {
      if (level.id == id) return level;
    }
    return null;
  }
}
