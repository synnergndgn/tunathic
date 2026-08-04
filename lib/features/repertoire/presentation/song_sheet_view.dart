import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/features/repertoire/domain/song_sheet.dart';
import 'package:tunathic/l10n/app_localizations.dart';

/// Where a chord can be placed.
enum SheetChordTargetKind {
  /// On a lyric fragment.
  word,

  /// Past the last word of a line, for a chord that lands with no syllable.
  lineEnd,

  /// On an empty line, which is where an intro or instrumental break goes.
  emptyLine,
}

/// A spot the performer can put a chord on, with the chord already there.
final class SheetChordTarget {
  const SheetChordTarget({
    required this.offset,
    this.kind = SheetChordTargetKind.word,
    this.word = '',
    this.chord,
  });

  /// Index in the song text where a new chord bracket belongs.
  final int offset;

  final SheetChordTargetKind kind;

  /// The lyric fragment under the chord, empty when there is no word.
  final String word;

  /// The chord already on this spot, when there is one.
  final ChordAnnotation? chord;
}

/// Renders a chord chart with each chord printed above the syllable it starts.
///
/// Lines wrap by word so a narrow screen never scrolls sideways, and the chord
/// stays attached to its own fragment instead of a fixed column. When
/// [onSelectWord] is set the fragments become buttons, which is how chords are
/// placed without typing brackets.
final class SongSheetView extends StatelessWidget {
  const SongSheetView({super.key, required this.sheet, this.onSelectWord});

  final SongSheet sheet;
  final ValueChanged<SheetChordTarget>? onSelectWord;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chordStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w700,
    );
    final lyricStyle = theme.textTheme.bodyLarge;
    final sectionStyle = theme.textTheme.titleSmall?.copyWith(
      color: theme.colorScheme.secondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in sheet.lines)
          switch (line.kind) {
            SongLineKind.blank =>
              onSelectWord == null
                  ? const SizedBox(height: AppSpacing.medium)
                  : _AddChordSlot(
                      onTap: () => onSelectWord!(
                        SheetChordTarget(
                          offset: line.sourceStart,
                          kind: SheetChordTargetKind.emptyLine,
                        ),
                      ),
                    ),
            SongLineKind.section => Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.small,
                bottom: AppSpacing.xSmall,
              ),
              child: Semantics(
                header: true,
                child: Text(line.label, style: sectionStyle),
              ),
            ),
            SongLineKind.lyrics => _LyricLine(
              line: line,
              chordStyle: chordStyle,
              lyricStyle: lyricStyle,
              onSelectWord: onSelectWord,
            ),
          },
      ],
    );
  }
}

final class _LyricLine extends StatelessWidget {
  const _LyricLine({
    required this.line,
    required this.chordStyle,
    required this.lyricStyle,
    required this.onSelectWord,
  });

  final SongSheetLine line;
  final TextStyle? chordStyle;
  final TextStyle? lyricStyle;
  final ValueChanged<SheetChordTarget>? onSelectWord;

  @override
  Widget build(BuildContext context) {
    final units = _units;
    final select = onSelectWord;
    final wrap = Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        for (final unit in units) _buildUnit(context, unit),
        // A chord can land after the last syllable of a line, so editing needs
        // a target past the words as well as on them.
        if (select != null)
          _AddChordSlot(
            compact: true,
            onTap: () => select(
              SheetChordTarget(
                offset: line.sourceEnd,
                kind: SheetChordTargetKind.lineEnd,
              ),
            ),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xSmall),
      child: onSelectWord == null
          // Reading mode announces the whole line at once; hearing it word by
          // word would be unusable.
          ? Semantics(
              label: _semanticsLabel,
              child: ExcludeSemantics(child: wrap),
            )
          : wrap,
    );
  }

  Widget _buildUnit(BuildContext context, _SheetUnit unit) {
    final showChords = line.hasChords || onSelectWord != null;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showChords) Text(unit.chord?.text ?? '', style: chordStyle),
        Text(unit.text, style: lyricStyle),
      ],
    );

    final select = onSelectWord;
    final word = unit.text.trim();
    // A chord standing on its own, as on an instrumental line, has no word but
    // still has to be reachable so it can be changed or removed.
    if (select == null || (word.isEmpty && unit.chord == null)) return content;

    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: switch ((unit.chord, word.isEmpty)) {
        (final chord?, true) => localizations.changeChord(chord.text),
        (final chord?, false) => localizations.changeChordOn(chord.text, word),
        (null, _) => localizations.placeChordOn(word),
      },
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: AppRadii.smallBorder,
          onTap: () => select(
            SheetChordTarget(
              offset: unit.offset,
              word: word,
              chord: unit.chord,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadii.smallBorder,
              border: Border.all(
                color: unit.chord == null
                    ? theme.colorScheme.outlineVariant
                    : theme.colorScheme.primary,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xSmall,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  String get _semanticsLabel {
    final lyrics = line.lyrics.trim();
    if (!line.hasChords) return lyrics;
    final chords = [
      for (final segment in line.segments)
        if (segment.chord != null) segment.chord!.text,
    ].join(' ');
    return lyrics.isEmpty ? chords : '$chords. $lyrics';
  }

  /// Splits the line into wrappable pieces, keeping each chord on the piece it
  /// was written against and each piece on its own source offset.
  List<_SheetUnit> get _units {
    final units = <_SheetUnit>[];
    for (final segment in line.segments) {
      var chord = segment.chord;
      if (segment.lyrics.isEmpty) {
        if (chord != null) {
          units.add(
            _SheetUnit(chord: chord, text: ' ', offset: segment.lyricsOffset),
          );
        }
        continue;
      }
      for (final piece in _piecePattern.allMatches(segment.lyrics)) {
        units.add(
          _SheetUnit(
            chord: chord,
            text: piece.group(0)!,
            offset: segment.lyricsOffset + piece.start,
          ),
        );
        chord = null;
      }
    }
    return units;
  }

  static final _piecePattern = RegExp(r'\S+\s*|\s+');
}

/// A `+` target for a chord that has no word under it.
final class _AddChordSlot extends StatelessWidget {
  const _AddChordSlot({required this.onTap, this.compact = false});

  final VoidCallback onTap;

  /// Inline at the end of a lyric line, rather than alone on a blank line.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final label = compact
        ? localizations.addChordAtLineEnd
        : localizations.addChordOnEmptyLine;

    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: IconButton.outlined(
            key: Key(compact ? 'addChordAtLineEnd' : 'addChordOnEmptyLine'),
            tooltip: label,
            visualDensity: VisualDensity.compact,
            onPressed: onTap,
            icon: const Icon(Icons.add, size: 18),
          ),
        ),
      ),
    );
  }
}

final class _SheetUnit {
  const _SheetUnit({
    required this.chord,
    required this.text,
    required this.offset,
  });

  final ChordAnnotation? chord;
  final String text;
  final int offset;
}
