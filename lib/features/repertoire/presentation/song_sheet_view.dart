import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/features/repertoire/domain/song_sheet.dart';

/// Renders a chord chart with each chord printed above the syllable it starts.
///
/// Lines wrap by word so a narrow screen never scrolls sideways, and the chord
/// stays attached to its own fragment instead of a fixed column.
final class SongSheetView extends StatelessWidget {
  const SongSheetView({super.key, required this.sheet});

  final SongSheet sheet;

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
            SongLineKind.blank => const SizedBox(height: AppSpacing.medium),
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
  });

  final SongSheetLine line;
  final TextStyle? chordStyle;
  final TextStyle? lyricStyle;

  @override
  Widget build(BuildContext context) {
    final showChords = line.hasChords;
    return Semantics(
      label: _semanticsLabel,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xSmall),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              for (final unit in _units)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showChords)
                      Text(unit.chord?.text ?? '', style: chordStyle),
                    Text(unit.text, style: lyricStyle),
                  ],
                ),
            ],
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
  /// was written against.
  List<_SheetUnit> get _units {
    final units = <_SheetUnit>[];
    for (final segment in line.segments) {
      var chord = segment.chord;
      if (segment.lyrics.isEmpty) {
        if (chord != null) units.add(_SheetUnit(chord: chord, text: ' '));
        continue;
      }
      for (final piece in _piecePattern.allMatches(segment.lyrics)) {
        units.add(_SheetUnit(chord: chord, text: piece.group(0)!));
        chord = null;
      }
    }
    return units;
  }

  static final _piecePattern = RegExp(r'\S+\s*|\s+');
}

final class _SheetUnit {
  const _SheetUnit({required this.chord, required this.text});

  final ChordAnnotation? chord;
  final String text;
}
