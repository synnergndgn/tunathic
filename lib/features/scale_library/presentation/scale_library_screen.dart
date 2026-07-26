import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/scale_library/domain/scale_search_parser.dart';
import 'package:tunathic/features/fretboard/domain/fretboard_route_state.dart';
import 'package:tunathic/features/scale_library/presentation/scale_library_localizations.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/pitch_class_selector.dart';

final class ScaleLibraryScreen extends StatefulWidget {
  const ScaleLibraryScreen({super.key});

  @override
  State<ScaleLibraryScreen> createState() => _ScaleLibraryScreenState();
}

final class _ScaleLibraryScreenState extends State<ScaleLibraryScreen> {
  static const _roots = [
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

  final _searchController = TextEditingController();
  SpelledPitchClass _root = _roots.first.spelling;
  ScaleDefinition _definition = ScaleDefinition.major;
  bool _searchHasError = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scale = ScaleConstructor.construct(
      root: _root,
      definition: _definition,
    );
    return Scaffold(
      appBar: AppBar(title: Text(localizations.scaleLibrary)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.pageMaxWidth,
            ),
            child: ListView(
              key: const Key('scaleLibraryScroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.large,
                AppSpacing.medium,
                AppSpacing.xLarge,
              ),
              children: [
                Text(
                  localizations.scaleLibraryIntro,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.large),
                _buildSearch(localizations),
                const SizedBox(height: AppSpacing.large),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final rootSelector = PitchClassSelector(
                      label: localizations.rootNoteLabel,
                      choices: _roots,
                      selectedRoot: _root,
                      keyPrefix: 'scaleRoot',
                      onSelected: (root) {
                        setState(() {
                          _root = root;
                          _searchHasError = false;
                        });
                      },
                    );
                    final scaleSelector = _buildScaleSelector(localizations);
                    if (constraints.maxWidth < 760) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          rootSelector,
                          const SizedBox(height: AppSpacing.large),
                          scaleSelector,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: rootSelector),
                        const SizedBox(width: AppSpacing.xLarge),
                        Expanded(flex: 2, child: scaleSelector),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xLarge),
                _ScaleSummary(scale: scale),
                const SizedBox(height: AppSpacing.medium),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    key: const Key('scaleViewOnFretboard'),
                    onPressed: () {
                      context.push(
                        AppRoutes.fretboard(
                          FretboardRouteState(
                            mode: FretboardMode.scale,
                            root: _root,
                            scaleDefinition: _definition,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.grid_on_outlined),
                    label: Text(localizations.viewOnFretboard),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                _ScaleDetails(scale: scale),
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
      label: localizations.scaleSearchLabel,
      child: TextField(
        key: const Key('scaleSearchField'),
        controller: _searchController,
        textInputAction: TextInputAction.search,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: localizations.scaleSearchLabel,
          hintText: localizations.scaleSearchHint,
          errorText: _searchHasError
              ? localizations.unsupportedScaleSearch
              : null,
          suffixIcon: IconButton(
            key: const Key('submitScaleSearch'),
            tooltip: localizations.searchAction,
            onPressed: _submitSearch,
            icon: const Icon(Icons.search),
          ),
        ),
        onSubmitted: (_) => _submitSearch(),
      ),
    );
  }

  Widget _buildScaleSelector(AppLocalizations localizations) {
    return DropdownButtonFormField<ScaleDefinition>(
      key: const Key('scaleTypeSelector'),
      initialValue: _definition,
      isExpanded: true,
      decoration: InputDecoration(labelText: localizations.scaleTypeLabel),
      items: [
        for (final definition in ScaleDefinition.values)
          DropdownMenuItem(
            value: definition,
            child: Text(
              '${localizations.scaleName(definition)}'
              ' · ${localizations.scaleCategoryName(definition.category)}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (definition) {
        if (definition == null) return;
        setState(() {
          _definition = definition;
          _searchHasError = false;
        });
      },
    );
  }

  void _submitSearch() {
    final parsed = ScaleSearchParser.tryParse(_searchController.text);
    if (parsed == null) {
      setState(() => _searchHasError = true);
      return;
    }
    setState(() {
      _root = parsed.root;
      _definition = parsed.definition;
      _searchHasError = false;
    });
  }
}

final class _ScaleSummary extends StatelessWidget {
  const _ScaleSummary({required this.scale});

  final ConstructedScale scale;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final name =
        '${scale.root.symbol} ${localizations.scaleName(scale.definition)}';
    final noteNames = scale.tones.map((tone) => tone.symbol).toList();
    final spokenFormula = scale.definition.degrees
        .map(localizations.scaleDegreeSpoken)
        .join(', ');

    return Semantics(
      label: localizations.scaleSummarySemantics(
        name,
        noteNames.join(', '),
        spokenFormula,
      ),
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: AppRadii.mediumBorder,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  key: const Key('scaleName'),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final notes = _LabeledTokens(
                      label: localizations.scaleNotesLabel,
                      tokens: noteNames,
                      key: const Key('scaleNotes'),
                    );
                    final formula = _LabeledTokens(
                      label: localizations.scaleFormulaLabel,
                      tokens: scale.definition.degrees
                          .map((degree) => degree.symbol)
                          .toList(),
                      key: const Key('scaleFormula'),
                    );
                    if (constraints.maxWidth < 600) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          notes,
                          const SizedBox(height: AppSpacing.large),
                          formula,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: notes),
                        const SizedBox(width: AppSpacing.xLarge),
                        Expanded(child: formula),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _LabeledTokens extends StatelessWidget {
  const _LabeledTokens({required this.label, required this.tokens, super.key});

  final String label;
  final List<String> tokens;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.small),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final token in tokens)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.75),
                  border: Border.all(color: colors.outlineVariant),
                  borderRadius: AppRadii.smallBorder,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.small,
                    vertical: AppSpacing.xSmall,
                  ),
                  child: Text(
                    token,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

final class _ScaleDetails extends StatelessWidget {
  const _ScaleDetails({required this.scale});

  final ConstructedScale scale;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final aliases = scale.definition.aliases
        .map(localizations.scaleAliasName)
        .join(', ');
    final relationships = _relationshipRows(localizations);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: AppRadii.mediumBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final metadata = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  label: localizations.scaleCategoryLabel,
                  value: localizations.scaleCategoryName(
                    scale.definition.category,
                  ),
                ),
                if (aliases.isNotEmpty)
                  _DetailRow(
                    label: localizations.scaleAliasesLabel,
                    value: aliases,
                  ),
                if (scale.definition == ScaleDefinition.melodicMinor)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.small),
                    child: Text(localizations.ascendingMelodicMinorNote),
                  ),
              ],
            );
            final relationshipContent = Column(
              key: const Key('scaleRelationships'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    localizations.scaleRelationshipsLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                ...relationships,
              ],
            );
            if (constraints.maxWidth < 700) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  metadata,
                  if (relationships.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.large),
                    relationshipContent,
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: metadata),
                if (relationships.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.xLarge),
                  Expanded(child: relationshipContent),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _relationshipRows(AppLocalizations localizations) {
    if (scale.definition == ScaleDefinition.major) {
      final relative = ScaleRelationships.relativeMinor(scale.root);
      return [
        _DetailRow(
          label: localizations.relativeMinorLabel,
          value:
              '${relative.symbol} '
              '${localizations.scaleName(ScaleDefinition.naturalMinor)}',
        ),
      ];
    }
    if (scale.definition == ScaleDefinition.naturalMinor) {
      final relative = ScaleRelationships.relativeMajor(scale.root);
      return [
        _DetailRow(
          label: localizations.relativeMajorLabel,
          value:
              '${relative.symbol} '
              '${localizations.scaleName(ScaleDefinition.major)}',
        ),
      ];
    }
    if (scale.definition.category == ScaleCategory.modes) {
      final parent = ScaleRelationships.parentMajor(
        modeRoot: scale.root,
        definition: scale.definition,
      );
      return [
        _DetailRow(
          label: localizations.parentMajorLabel,
          value:
              '${parent!.symbol} '
              '${localizations.scaleName(ScaleDefinition.major)}',
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.small),
          child: Text(
            localizations.modeDegreeValue(scale.definition.modeDegree!),
            key: const Key('modeDegree'),
          ),
        ),
      ];
    }
    return const [];
  }
}

final class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
