import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/music_theory/chord_symbol_parser.dart';
import 'package:tunathic/core/music_theory/pitch_class.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/pitch_class_selector.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

/// What the performer chose in the chord picker.
sealed class ChordPickerResult {
  const ChordPickerResult();
}

final class ChordChosen extends ChordPickerResult {
  const ChordChosen(this.symbol);

  final String symbol;
}

final class ChordCleared extends ChordPickerResult {
  const ChordCleared();
}

/// Picks a chord for one word: a root, then a quality, in two taps.
///
/// Chords already used in the song come first, because a typical chart repeats
/// four or five of them and reusing one should cost a single tap.
final class ChordPickerSheet extends StatefulWidget {
  const ChordPickerSheet({
    super.key,
    this.word = '',
    this.currentChord,
    this.songChords = const [],
  });

  /// The lyric fragment the chord lands on, empty when there is no word.
  final String word;
  final String? currentChord;
  final List<String> songChords;

  static Future<ChordPickerResult?> show(
    BuildContext context, {
    String word = '',
    String? currentChord,
    List<String> songChords = const [],
  }) => showModalBottomSheet<ChordPickerResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    builder: (context) => SkeuoSurface(
      prominent: true,
      padding: const EdgeInsets.only(top: AppSpacing.medium),
      child: ChordPickerSheet(
        word: word,
        currentChord: currentChord,
        songChords: songChords,
      ),
    ),
  );

  @override
  State<ChordPickerSheet> createState() => _ChordPickerSheetState();
}

class _ChordPickerSheetState extends State<ChordPickerSheet> {
  static const _qualities = [
    '',
    'm',
    '7',
    'm7',
    'maj7',
    'sus2',
    'sus4',
    'add9',
    '6',
    'm6',
    '9',
    '5',
    'dim',
    'aug',
  ];

  late SpelledPitchClass _root = _initialRoot();

  SpelledPitchClass _initialRoot() {
    final current = widget.currentChord;
    final parsed = current == null
        ? null
        : ChordSymbolParser.tryParseWritten(current);
    return parsed?.root ??
        const SpelledPitchClass(
          letter: NoteLetter.c,
          accidental: Accidental.natural,
        );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('chordPickerScroll'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          0,
          AppSpacing.medium,
          AppSpacing.medium,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                widget.word.isEmpty
                    ? localizations.chordPickerTitleNoWord
                    : localizations.chordPickerTitle(widget.word),
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            if (widget.currentChord != null) ...[
              SkeuoButton(
                key: const Key('chordPickerRemove'),
                icon: Icons.backspace_outlined,
                onPressed: () =>
                    Navigator.of(context).pop(const ChordCleared()),
                child: Text(localizations.removeChord),
              ),
              const SizedBox(height: AppSpacing.large),
            ],
            if (widget.songChords.isNotEmpty) ...[
              Text(
                localizations.chordsUsedInSong,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  for (final chord in widget.songChords)
                    SkeuoButton(
                      key: Key('chordPickerRecent-$chord'),
                      compact: true,
                      onPressed: () => _choose(chord),
                      child: Text(chord),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.large),
            ],
            PitchClassSelector(
              label: localizations.chordPickerRoot,
              choices: chromaticPitchClassChoices,
              selectedRoot: _root,
              keyPrefix: 'chordPickerRoot',
              onSelected: (root) => setState(() => _root = root),
            ),
            const SizedBox(height: AppSpacing.large),
            Semantics(
              header: true,
              child: Text(
                localizations.chordPickerQuality,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                for (final quality in _qualities)
                  SkeuoButton(
                    key: Key('chordPickerQuality-$quality'),
                    compact: true,
                    onPressed: () => _choose('${_root.symbol}$quality'),
                    child: Text('${_root.symbol}$quality'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _choose(String symbol) => Navigator.of(context).pop(ChordChosen(symbol));
}
