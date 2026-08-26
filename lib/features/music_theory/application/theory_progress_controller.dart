import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/features/music_theory/application/theory_progress_repository.dart';
import 'package:tunathic/features/music_theory/domain/theory_library.dart';
import 'package:tunathic/features/music_theory/domain/theory_progress.dart';

final theoryProgressProvider =
    AsyncNotifierProvider<TheoryProgressController, TheoryProgress>(
      TheoryProgressController.new,
    );

/// Owns starred and recently read lessons.
///
/// Stored identifiers are pruned against the catalog on load, so a lesson that
/// is renamed or retired cannot leave a dead entry in the hub.
final class TheoryProgressController extends AsyncNotifier<TheoryProgress> {
  @override
  Future<TheoryProgress> build() async {
    final stored = await ref.watch(theoryProgressRepositoryProvider).load();
    return stored.prunedTo(TheoryLibrary.lessonIds);
  }

  Future<void> toggleFavorite(String lessonId) =>
      _commit(_current.toggleFavorite(lessonId));

  Future<void> markViewed(String lessonId) async {
    if (_current.recentIds.firstOrNull == lessonId) return;
    await _commit(_current.markViewed(lessonId));
  }

  TheoryProgress get _current => state.value ?? TheoryProgress.empty;

  Future<void> _commit(TheoryProgress progress) async {
    state = AsyncData(progress);
    await ref.read(theoryProgressRepositoryProvider).save(progress);
  }
}
