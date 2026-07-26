import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/music_theory/pitch_class.dart';

final class PitchClassChoice {
  const PitchClassChoice({required this.spelling, this.label});

  final SpelledPitchClass spelling;
  final String? label;

  String get displayLabel => label ?? spelling.symbol;
}

const chromaticPitchClassChoices = [
  PitchClassChoice(
    spelling: SpelledPitchClass(
      letter: NoteLetter.c,
      accidental: Accidental.natural,
    ),
  ),
  PitchClassChoice(
    spelling: SpelledPitchClass(
      letter: NoteLetter.d,
      accidental: Accidental.flat,
    ),
    label: 'Db / C#',
  ),
  PitchClassChoice(
    spelling: SpelledPitchClass(
      letter: NoteLetter.d,
      accidental: Accidental.natural,
    ),
  ),
  PitchClassChoice(
    spelling: SpelledPitchClass(
      letter: NoteLetter.e,
      accidental: Accidental.flat,
    ),
    label: 'Eb / D#',
  ),
  PitchClassChoice(
    spelling: SpelledPitchClass(
      letter: NoteLetter.e,
      accidental: Accidental.natural,
    ),
  ),
  PitchClassChoice(
    spelling: SpelledPitchClass(
      letter: NoteLetter.f,
      accidental: Accidental.natural,
    ),
  ),
  PitchClassChoice(
    spelling: SpelledPitchClass(
      letter: NoteLetter.f,
      accidental: Accidental.sharp,
    ),
    label: 'F# / Gb',
  ),
  PitchClassChoice(
    spelling: SpelledPitchClass(
      letter: NoteLetter.g,
      accidental: Accidental.natural,
    ),
  ),
  PitchClassChoice(
    spelling: SpelledPitchClass(
      letter: NoteLetter.a,
      accidental: Accidental.flat,
    ),
    label: 'Ab / G#',
  ),
  PitchClassChoice(
    spelling: SpelledPitchClass(
      letter: NoteLetter.a,
      accidental: Accidental.natural,
    ),
  ),
  PitchClassChoice(
    spelling: SpelledPitchClass(
      letter: NoteLetter.b,
      accidental: Accidental.flat,
    ),
    label: 'Bb / A#',
  ),
  PitchClassChoice(
    spelling: SpelledPitchClass(
      letter: NoteLetter.b,
      accidental: Accidental.natural,
    ),
  ),
];

final class PitchClassSelector extends StatelessWidget {
  const PitchClassSelector({
    required this.label,
    required this.choices,
    required this.selectedRoot,
    required this.onSelected,
    required this.keyPrefix,
    super.key,
  });

  final String label;
  final List<PitchClassChoice> choices;
  final SpelledPitchClass selectedRoot;
  final ValueChanged<SpelledPitchClass> onSelected;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: AppSpacing.small),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final choice in choices)
              ChoiceChip(
                key: Key('$keyPrefix-${choice.spelling.symbol}'),
                label: Text(choice.displayLabel),
                selected: selectedRoot.pitchClass == choice.spelling.pitchClass,
                onSelected: (_) => onSelected(choice.spelling),
              ),
          ],
        ),
      ],
    );
  }
}
