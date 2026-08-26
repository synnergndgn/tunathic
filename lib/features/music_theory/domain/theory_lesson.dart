import 'package:tunathic/features/music_theory/domain/theory_action.dart';
import 'package:tunathic/features/music_theory/domain/theory_block.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';

/// One lesson in the Music Theory hub.
///
/// A lesson is structure only. Its prose lives in the per-locale content maps
/// and is addressed by identifier, and its examples are structural values that
/// the shared theory engine renders.
final class TheoryLesson {
  const TheoryLesson({
    required this.id,
    required this.category,
    required this.level,
    required this.blocks,
    this.aliases = const [],
    this.titleOverrideId,
  });

  final String id;
  final TheoryCategory category;
  final TheoryLevel level;
  final List<TheoryBlock> blocks;

  /// Language-neutral search terms such as `P5`, `m3`, or `CAGED`.
  final List<String> aliases;

  /// Set when a lesson borrows an existing name instead of defining one.
  final String? titleOverrideId;

  /// Interval lessons share their title with the interval's display name, so
  /// the name is written once and used by both the lesson and its diagrams.
  String get titleId => titleOverrideId ?? '$id.title';

  String get summaryId => '$id.summary';

  /// Extra translated search terms, so a Turkish reader can search in Turkish.
  String get keywordsId => '$id.keywords';

  /// Every "Try it" target the lesson offers, in reading order.
  Iterable<TheoryAction> get actions sync* {
    for (final block in blocks) {
      if (block is TheoryTryIt) yield block.action;
    }
  }

  /// Every content identifier the lesson needs, used by the localization test
  /// to prove English and Turkish both cover the whole hub.
  Iterable<String> get textIds sync* {
    yield titleId;
    yield summaryId;
    yield keywordsId;
    for (final block in blocks) {
      switch (block) {
        case TheoryParagraph(:final textId) || TheoryHeading(:final textId):
          yield textId;
        case TheoryBullets(:final textIds):
          yield* textIds;
        case TheoryFacts(:final facts):
          for (final fact in facts) {
            yield fact.labelId;
            yield fact.valueId;
          }
        case TheoryScaleExample(:final captionId) ||
            TheoryChordExample(:final captionId) ||
            TheoryFretboardDiagram(:final captionId) ||
            TheoryTuningTable(:final captionId):
          if (captionId != null) yield captionId;
        case TheoryNoteValueChart(:final values):
          for (final value in values) {
            yield value.nameId;
          }
        case TheoryChordFormula() ||
            TheoryIntervalProfile() ||
            TheoryDiatonicTable() ||
            TheoryKeySignatureTable() ||
            TheoryTryIt():
          break;
      }
    }
  }
}
