import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/music_theory/chord_symbol_parser.dart';
import 'package:tunathic/core/music_theory/pitch_class.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/pitch_class_selector.dart';

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
    required this.word,
    this.currentChord,
    this.songChords = const [],
  });

  final String word;
  final String? currentChord;
  final List<String> songChords;

  static Future<ChordPickerResult?> show(
    BuildContext context, {
    required String word,
    String? currentChord,
    List<String> songChords = const [],
  }) => showModalBottomSheet<ChordPickerResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => ChordPickerSheet(
      word: word,
      currentChord: currentChord,
      songChords: songChords,
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
                localizations.chordPickerTitle(widget.word),
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
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
                    ActionChip(
                      key: Key('chordPickerRecent-$chord'),
                      label: Text(chord),
                      onPressed: () => _choose(chord),
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
                  ActionChip(
                    key: Key('chordPickerQuality-$quality'),
                    label: Text('${_root.symbol}$quality'),
                    onPressed: () => _choose('${_root.symbol}$quality'),
                  ),
              ],
            ),
            if (widget.currentChord != null) ...[
              const SizedBox(height: AppSpacing.large),
              OutlinedButton.icon(
                key: const Key('chordPickerRemove'),
                onPressed: () =>
                    Navigator.of(context).pop(const ChordCleared()),
                icon: const Icon(Icons.backspace_outlined),
                label: Text(localizations.removeChord),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _choose(String symbol) => Navigator.of(context).pop(ChordChosen(symbol));
}
