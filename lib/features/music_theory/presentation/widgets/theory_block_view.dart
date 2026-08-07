import 'package:flutter/material.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/music_theory/domain/interval_shape.dart';
import 'package:tunathic/features/music_theory/domain/theory_action.dart';
import 'package:tunathic/features/music_theory/domain/theory_block.dart';
import 'package:tunathic/features/music_theory/domain/theory_content.dart';
import 'package:tunathic/features/music_theory/domain/theory_interval_facts.dart';
import 'package:tunathic/features/music_theory/presentation/theory_localizations.dart';
import 'package:tunathic/features/music_theory/presentation/widgets/theory_fretboard_view.dart';
import 'package:tunathic/features/music_theory/presentation/widgets/theory_note_chips.dart';
import 'package:tunathic/features/music_theory/presentation/widgets/theory_note_value_chart.dart';
import 'package:tunathic/features/circle_of_fifths/presentation/circle_of_fifths_localizations.dart';
import 'package:tunathic/features/scale_library/presentation/scale_library_localizations.dart';
import 'package:tunathic/features/tuner/presentation/tuner_localizations.dart';
import 'package:tunathic/l10n/app_localizations.dart';

/// Renders one lesson block.
///
/// Every musical value shown here is produced by the shared theory engine at
/// build time. Nothing in a lesson stores a precomputed note list, so an
/// example cannot fall out of step with the libraries it links to.
final class TheoryBlockView extends StatelessWidget {
  const TheoryBlockView({
    required this.block,
    required this.content,
    required this.onOpenAction,
    super.key,
  });

  final TheoryBlock block;
  final TheoryContent content;
  final ValueChanged<String> onOpenAction;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return switch (block) {
      TheoryParagraph(:final textId) => Text(
        content.text(textId),
        style: theme.textTheme.bodyLarge,
      ),
      TheoryHeading(:final textId) => Semantics(
        header: true,
        child: Text(content.text(textId), style: theme.textTheme.titleMedium),
      ),
      TheoryBullets(:final textIds) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final textId in textIds)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.small),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: Text(
                      content.text(textId),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      TheoryFacts(:final facts) => _FactTable(facts: facts, content: content),
      final TheoryScaleExample scale => _ScaleExample(
        block: scale,
        content: content,
      ),
      final TheoryChordExample chord => _ChordExample(
        block: chord,
        content: content,
      ),
      TheoryChordFormula(:final quality) => _ChordFormula(quality: quality),
      final TheoryIntervalProfile profile => _IntervalProfile(
        block: profile,
        content: content,
      ),
      final TheoryFretboardDiagram diagram => _FretboardDiagram(
        block: diagram,
        content: content,
      ),
      final TheoryDiatonicTable diatonic => _DiatonicTable(block: diatonic),
      TheoryKeySignatureTable(:final keys) => _KeySignatureTable(keys: keys),
      TheoryNoteValueChart(:final values) => _LabelledSection(
        label: localizations.theoryNoteValuesLabel,
        child: TheoryNoteValueChartView(values: values, content: content),
      ),
      final TheoryTuningTable tuning => _TuningTable(
        block: tuning,
        content: content,
      ),
      TheoryTryIt(:final action) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: FilledButton.tonalIcon(
          key: Key('theoryAction_${action.tool.id}'),
          onPressed: () => onOpenAction(AppRoutes.theoryAction(action)),
          icon: Icon(action.tool.icon),
          label: Text(_actionLabel(localizations, action)),
        ),
      ),
    };
  }

  /// Actions name their target, so a reader knows what will open.
  static String _actionLabel(
    AppLocalizations localizations,
    TheoryAction action,
  ) {
    final base = localizations.theoryActionLabel(action);
    return switch (action) {
      OpenChordLibraryAction(:final chordSymbol) => '$base · $chordSymbol',
      OpenScaleLibraryAction(:final root, :final definition) =>
        '$base · ${root.symbol} ${localizations.scaleName(definition)}',
      _ => base,
    };
  }
}

final class _LabelledSection extends StatelessWidget {
  const _LabelledSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      const SizedBox(height: AppSpacing.small),
      child,
    ],
  );
}

final class _FactTable extends StatelessWidget {
  const _FactTable({required this.facts, required this.content});

  final List<TheoryFact> facts;
  final TheoryContent content;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final fact in facts)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.small),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  content.text(fact.labelId),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(
                  content.text(fact.valueId),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

final class _ScaleExample extends StatelessWidget {
  const _ScaleExample({required this.block, required this.content});

  final TheoryScaleExample block;
  final TheoryContent content;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scale = block.scale;
    final notes = [
      for (var index = 0; index < scale.tones.length; index++)
        TheoryNoteChipData(
          note: scale.tones[index].symbol,
          degree: scale.definition.degrees[index].symbol,
          isRoot: index == 0,
        ),
    ];
    return _ExampleCard(
      caption: block.captionId == null ? null : content.text(block.captionId!),
      children: [
        TheoryNoteChips(
          notes: notes,
          semanticLabel:
              '${localizations.theoryNotesLabel}: '
              '${scale.tones.map((tone) => tone.symbol).join(', ')}',
        ),
        const SizedBox(height: AppSpacing.small),
        _FormulaLine(formula: scale.definition.formula),
      ],
    );
  }
}

final class _ChordExample extends StatelessWidget {
  const _ChordExample({required this.block, required this.content});

  final TheoryChordExample block;
  final TheoryContent content;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final chord = block.chord;
    final notes = [
      for (var index = 0; index < chord.tones.length; index++)
        TheoryNoteChipData(
          note: chord.tones[index].symbol,
          degree: chordDegreeSymbol(chord.quality.formula[index]),
          isRoot: index == 0,
        ),
    ];
    return _ExampleCard(
      caption: block.captionId == null ? null : content.text(block.captionId!),
      children: [
        Text(chord.symbol, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.small),
        TheoryNoteChips(
          notes: notes,
          semanticLabel:
              '${chord.symbol}. ${localizations.theoryNotesLabel}: '
              '${chord.tones.map((tone) => tone.symbol).join(', ')}',
        ),
      ],
    );
  }
}

final class _ChordFormula extends StatelessWidget {
  const _ChordFormula({required this.quality});

  final ChordQuality quality;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final formula = quality.formula.map(chordDegreeSymbol).join(' · ');
    final symbol = quality.symbol.isEmpty ? 'maj' : quality.symbol;
    return Semantics(
      label: '$symbol. ${localizations.theoryFormulaLabel}: $formula',
      child: ExcludeSemantics(
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                symbol,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                formula,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _FormulaLine extends StatelessWidget {
  const _FormulaLine({required this.formula});

  final String formula;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Text(
      '${localizations.theoryFormulaLabel}: $formula',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}

final class _IntervalProfile extends StatelessWidget {
  const _IntervalProfile({required this.block, required this.content});

  final TheoryIntervalProfile block;
  final TheoryContent content;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final interval = block.interval;
    final shape = IntervalShapes.findFrom(interval: interval);
    final strings = GuitarTuning.standard.strings;

    return _ExampleCard(
      caption: null,
      children: [
        Wrap(
          spacing: AppSpacing.large,
          runSpacing: AppSpacing.small,
          children: [
            _Fact(
              label: localizations.theorySemitonesLabel,
              value: '${interval.semitones}',
            ),
            _Fact(
              label: localizations.theoryQualityLabel,
              value: content.text(interval.qualityId),
            ),
            _Fact(
              label: localizations.theoryShorthandLabel,
              value: interval.shortLabel,
            ),
            if (block.enharmonic case final enharmonic?)
              _Fact(
                label: localizations.theoryAlsoSpelledLabel,
                value:
                    '${content.text(enharmonic.nameId)} '
                    '(${enharmonic.shortLabel})',
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        TheoryNoteChips(
          notes: [
            TheoryNoteChipData(
              note: block.root.symbol,
              degree: '1',
              isRoot: true,
            ),
            TheoryNoteChipData(
              note: block.target.symbol,
              degree: interval.shortLabel,
            ),
          ],
          semanticLabel:
              '${localizations.theoryNotesLabel}: '
              '${block.root.symbol}, ${block.target.symbol}',
        ),
        if (shape != null) ...[
          const SizedBox(height: AppSpacing.medium),
          _LabelledSection(
            label: localizations.theoryGuitarShapeLabel,
            child: TheoryFretboardView(
              markers: [
                TheoryFretMarker(
                  stringIndex: shape.rootStringIndex,
                  fret: shape.rootFret,
                  label: '1',
                  emphasis: TheoryMarkerEmphasis.root,
                ),
                TheoryFretMarker(
                  stringIndex: shape.targetStringIndex,
                  fret: shape.targetFret,
                  label: interval.shortLabel,
                  emphasis: TheoryMarkerEmphasis.target,
                ),
              ],
              firstFret: shape.lowestFret > 1 ? shape.lowestFret - 1 : 0,
              lastFret: shape.highestFret + 1,
              stringLabels: [for (final string in strings) string.label],
              semanticLabel: localizations.theoryIntervalShapeSemantics(
                content.text(interval.nameId),
                strings[shape.rootStringIndex].label,
                shape.rootFret,
                strings[shape.targetStringIndex].label,
                shape.targetFret,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

final class _FretboardDiagram extends StatelessWidget {
  const _FretboardDiagram({required this.block, required this.content});

  final TheoryFretboardDiagram block;
  final TheoryContent content;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final projection = block.projection;
    final positions = const GuitarFretboard().project(
      projection: projection,
      maximumFret: block.lastFret,
    );
    final members = [
      for (final position in positions)
        if (position.isMember && position.fret >= block.firstFret) position,
    ];
    final subject = switch (block.subject) {
      TheoryFretboardSubject.chord =>
        '${block.root.symbol}${block.quality!.symbol}',
      TheoryFretboardSubject.scale =>
        '${block.root.symbol} ${localizations.scaleName(block.definition!)}',
    };

    return _ExampleCard(
      caption: block.captionId == null ? null : content.text(block.captionId!),
      children: [
        Text(
          localizations.theoryFretRangeLabel(block.firstFret, block.lastFret),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        TheoryFretboardView(
          markers: [
            for (final position in members)
              TheoryFretMarker(
                stringIndex: position.stringIndex,
                fret: position.fret,
                label: position.relationshipSymbol ?? '',
                emphasis: position.isRoot
                    ? TheoryMarkerEmphasis.root
                    : TheoryMarkerEmphasis.member,
              ),
          ],
          firstFret: block.firstFret,
          lastFret: block.lastFret,
          stringLabels: [
            for (final string in GuitarTuning.standard.strings) string.label,
          ],
          semanticLabel: localizations.theoryFretboardSemantics(
            subject,
            block.firstFret,
            block.lastFret,
            projection.relations.values
                .map((relation) => relation.pitch.symbol)
                .join(', '),
          ),
        ),
      ],
    );
  }
}

final class _DiatonicTable extends StatelessWidget {
  const _DiatonicTable({required this.block});

  final TheoryDiatonicTable block;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final chords = block.chords;
    return _LabelledSection(
      label: localizations.theoryDiatonicChordsLabel(
        localizations.keyName(block.key),
      ),
      child: Wrap(
        spacing: AppSpacing.small,
        runSpacing: AppSpacing.small,
        children: [
          for (final chord in chords)
            Semantics(
              label: '${chord.romanNumeral.symbol}, ${chord.chord.symbol}',
              child: ExcludeSemantics(
                child: Container(
                  width: 82,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.small,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        chord.romanNumeral.symbol,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                      Text(
                        chord.chord.symbol,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _KeySignatureTable extends StatelessWidget {
  const _KeySignatureTable({required this.keys});

  final List<MusicalKey> keys;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return _LabelledSection(
      label: localizations.theoryKeySignaturesLabel,
      child: Column(
        children: [
          for (final key in keys)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.small),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      localizations.keyName(key),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: Text(
                      localizations.keySignatureDescription(key.keySignature),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

final class _TuningTable extends StatelessWidget {
  const _TuningTable({required this.block, required this.content});

  final TheoryTuningTable block;
  final TheoryContent content;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return _ExampleCard(
      caption: block.captionId == null ? null : content.text(block.captionId!),
      children: [
        for (final preset in block.presets)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 116,
                  child: Text(
                    localizations.tuningPresetName(preset.id),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    [
                      for (var position = 6; position >= 1; position--)
                        preset.stringAt(position).displayName,
                    ].join('  '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

final class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      Text(value, style: Theme.of(context).textTheme.titleMedium),
    ],
  );
}

final class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.caption, required this.children});

  final String? caption;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (caption != null) ...[
            Text(
              caption!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
          ],
          ...children,
        ],
      ),
    ),
  );
}
