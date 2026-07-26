import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/chord_library/data/guitar_chord_shapes.dart';
import 'package:tunathic/features/chord_library/domain/chord_library_route_state.dart';
import 'package:tunathic/features/chord_library/domain/guitar_chord_shape.dart';
import 'package:tunathic/features/chord_library/presentation/chord_diagram.dart';
import 'package:tunathic/features/chord_library/presentation/chord_library_localizations.dart';
import 'package:tunathic/features/fretboard/domain/fretboard_route_state.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/pitch_class_selector.dart';

final class ChordLibraryScreen extends StatefulWidget {
  const ChordLibraryScreen({
    this.initialState = const ChordLibraryRouteState(),
    super.key,
  });

  final ChordLibraryRouteState initialState;

  @override
  State<ChordLibraryScreen> createState() => _ChordLibraryScreenState();
}

final class _ChordLibraryScreenState extends State<ChordLibraryScreen> {
  static const _roots = [
    PitchClassChoice(
      spelling: SpelledPitchClass(
        letter: NoteLetter.c,
        accidental: Accidental.natural,
      ),
    ),
    PitchClassChoice(
      spelling: SpelledPitchClass(
        letter: NoteLetter.c,
        accidental: Accidental.sharp,
      ),
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
    ),
    PitchClassChoice(
      spelling: SpelledPitchClass(
        letter: NoteLetter.b,
        accidental: Accidental.natural,
      ),
    ),
  ];

  final _searchController = TextEditingController();
  late SpelledPitchClass _root;
  late ChordQuality _quality;
  int _shapeIndex = 0;
  bool _searchHasError = false;

  @override
  void initState() {
    super.initState();
    _root = widget.initialState.root;
    _quality = widget.initialState.quality;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final chord = ChordConstructor.construct(root: _root, quality: _quality);
    final shapes = GuitarChordShapes.forChord(_root.pitchClass, _quality);
    final selectedShape = shapes.isEmpty
        ? null
        : shapes[_shapeIndex.clamp(0, shapes.length - 1)];

    return Scaffold(
      appBar: AppBar(title: Text(localizations.chordLibrary)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.pageMaxWidth,
            ),
            child: ListView(
              key: const Key('chordLibraryScroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.large,
                AppSpacing.medium,
                AppSpacing.xLarge,
              ),
              children: [
                Text(
                  localizations.chordLibraryIntro,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.large),
                _buildSearch(localizations),
                const SizedBox(height: AppSpacing.large),
                _buildRootSelector(localizations),
                const SizedBox(height: AppSpacing.large),
                _buildQualitySelector(localizations),
                const SizedBox(height: AppSpacing.xLarge),
                _ChordSummary(chord: chord),
                const SizedBox(height: AppSpacing.medium),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    key: const Key('chordViewOnFretboard'),
                    onPressed: () {
                      context.push(
                        AppRoutes.fretboard(
                          FretboardRouteState(
                            mode: FretboardMode.chord,
                            root: _root,
                            chordQuality: _quality,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.grid_on_outlined),
                    label: Text(localizations.viewOnFretboard),
                  ),
                ),
                const SizedBox(height: AppSpacing.xLarge),
                Semantics(
                  header: true,
                  child: Text(
                    localizations.guitarShapesLabel,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                if (selectedShape == null)
                  _NoShapeState(chordSymbol: chord.symbol)
                else
                  _ShapeContent(
                    chordSymbol: chord.symbol,
                    shapes: shapes,
                    selectedIndex: _shapeIndex,
                    selectedShape: selectedShape,
                    onSelected: (index) {
                      setState(() => _shapeIndex = index);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearch(AppLocalizations localizations) {
    return Semantics(
      textField: true,
      label: localizations.chordSearchLabel,
      child: TextField(
        key: const Key('chordSearchField'),
        controller: _searchController,
        textInputAction: TextInputAction.search,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: localizations.chordSearchLabel,
          hintText: localizations.chordSearchHint,
          errorText: _searchHasError
              ? localizations.unsupportedChordSearch
              : null,
          suffixIcon: IconButton(
            key: const Key('submitChordSearch'),
            tooltip: localizations.searchAction,
            onPressed: _submitSearch,
            icon: const Icon(Icons.search),
          ),
        ),
        onSubmitted: (_) => _submitSearch(),
      ),
    );
  }

  Widget _buildRootSelector(AppLocalizations localizations) {
    return PitchClassSelector(
      label: localizations.rootNoteLabel,
      choices: _roots,
      selectedRoot: _root,
      keyPrefix: 'root',
      onSelected: (root) {
        setState(() {
          _root = root;
          _shapeIndex = 0;
          _searchHasError = false;
        });
      },
    );
  }

  Widget _buildQualitySelector(AppLocalizations localizations) {
    return DropdownButtonFormField<ChordQuality>(
      key: const Key('chordQualitySelector'),
      initialValue: _quality,
      isExpanded: true,
      decoration: InputDecoration(labelText: localizations.chordQualityLabel),
      items: [
        for (final quality in ChordQuality.values)
          DropdownMenuItem(
            value: quality,
            child: Text(
              '${localizations.chordQualityName(quality)}'
              ' · ${localizations.chordCategoryName(quality.category)}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (quality) {
        if (quality == null) return;
        setState(() {
          _quality = quality;
          _shapeIndex = 0;
          _searchHasError = false;
        });
      },
    );
  }

  void _submitSearch() {
    final parsed = ChordSymbolParser.tryParse(_searchController.text);
    if (parsed == null) {
      setState(() => _searchHasError = true);
      return;
    }
    setState(() {
      _root = parsed.root;
      _quality = parsed.quality;
      _shapeIndex = 0;
      _searchHasError = false;
    });
  }
}

final class _ChordSummary extends StatelessWidget {
  const _ChordSummary({required this.chord});

  final ConstructedChord chord;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadii.mediumBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Wrap(
          spacing: AppSpacing.xxLarge,
          runSpacing: AppSpacing.medium,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Semantics(
              label: '${localizations.chordSymbolLabel}: ${chord.symbol}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.chordSymbolLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    chord.symbol,
                    key: const Key('chordSymbol'),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              label:
                  '${localizations.chordTonesLabel}: '
                  '${chord.tones.map((tone) => tone.symbol).join(', ')}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.chordTonesLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    chord.tones.map((tone) => tone.symbol).join('  ·  '),
                    key: const Key('chordTones'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ShapeContent extends StatelessWidget {
  const _ShapeContent({
    required this.chordSymbol,
    required this.shapes,
    required this.selectedIndex,
    required this.selectedShape,
    required this.onSelected,
  });

  final String chordSymbol;
  final List<GuitarChordShape> shapes;
  final int selectedIndex;
  final GuitarChordShape selectedShape;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final alternatives = _ShapeChoices(
      shapes: shapes,
      selectedIndex: selectedIndex,
      onSelected: onSelected,
    );
    final diagram = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: ChordDiagram(
        key: ValueKey('diagram-${selectedShape.id}'),
        shape: selectedShape,
        chordSymbol: chordSymbol,
      ),
    );
    final details = _FingeringDetails(shape: selectedShape);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.alternateShapesLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.small),
              alternatives,
              const SizedBox(height: AppSpacing.large),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Center(child: diagram)),
                  const SizedBox(width: AppSpacing.xLarge),
                  Expanded(child: details),
                ],
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.alternateShapesLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.small),
            alternatives,
            const SizedBox(height: AppSpacing.large),
            Center(child: diagram),
            const SizedBox(height: AppSpacing.large),
            details,
          ],
        );
      },
    );
  }
}

final class _ShapeChoices extends StatelessWidget {
  const _ShapeChoices({
    required this.shapes,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<GuitarChordShape> shapes;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.small,
      runSpacing: AppSpacing.small,
      children: [
        for (var index = 0; index < shapes.length; index++)
          ChoiceChip(
            key: Key('shapeChoice-$index'),
            selected: selectedIndex == index,
            onSelected: (_) => onSelected(index),
            label: Text(
              [
                localizations.shapeCategoryName(shapes[index].category),
                if (shapes[index].startingFret > 1)
                  localizations.startingFretValue(shapes[index].startingFret),
              ].join(' · '),
            ),
          ),
      ],
    );
  }
}

final class _FingeringDetails extends StatelessWidget {
  const _FingeringDetails({required this.shape});

  final GuitarChordShape shape;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final stringNames = localizations.guitarStringNames;
    return Column(
      key: const Key('fingeringDetails'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            localizations.fingeringLabel,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          '${localizations.shapeCategoryName(shape.category)}'
          ' · ${localizations.shapeDifficultyName(shape.difficulty)}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        if (shape.startingFret > 1) ...[
          const SizedBox(height: AppSpacing.xSmall),
          Text(localizations.startingFretValue(shape.startingFret)),
        ],
        const SizedBox(height: AppSpacing.medium),
        for (var index = 0; index < shape.strings.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: Text(
              '${stringNames[index]}: ${_stringInstruction(localizations, shape.strings[index])}',
            ),
          ),
        for (final barre in shape.barres)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: Text(
              localizations.barreDescription(
                barre.fret,
                stringNames[barre.fromString],
                stringNames[barre.toStringIndex],
                barre.finger,
              ),
            ),
          ),
      ],
    );
  }

  String _stringInstruction(
    AppLocalizations localizations,
    GuitarStringFingering string,
  ) => switch (string.kind) {
    GuitarStringKind.muted => localizations.mutedMarker,
    GuitarStringKind.open => localizations.openMarker,
    GuitarStringKind.fretted when string.finger != null =>
      localizations.fretAndFingerValue(string.fret, string.finger!),
    GuitarStringKind.fretted => localizations.fretOnlyValue(string.fret),
  };
}

final class _NoShapeState extends StatelessWidget {
  const _NoShapeState({required this.chordSymbol});

  final String chordSymbol;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label:
          '$chordSymbol. ${localizations.noChordShapeTitle}. '
          '${localizations.noChordShapeDescription}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.outlineVariant),
          borderRadius: AppRadii.mediumBorder,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: colors.primary),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.noChordShapeTitle,
                      key: const Key('noChordShapeTitle'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(localizations.noChordShapeDescription),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
