import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/chord_library/presentation/chord_library_localizations.dart';
import 'package:tunathic/features/fretboard/domain/fretboard_route_state.dart';
import 'package:tunathic/features/fretboard/presentation/interactive_fretboard_view.dart';
import 'package:tunathic/features/scale_library/presentation/scale_library_localizations.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/pitch_class_selector.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/tunathic_scaffold.dart';

final class InteractiveFretboardScreen extends StatefulWidget {
  const InteractiveFretboardScreen({
    this.initialState = const FretboardRouteState(),
    super.key,
  });

  final FretboardRouteState initialState;

  @override
  State<InteractiveFretboardScreen> createState() =>
      _InteractiveFretboardScreenState();
}

final class _InteractiveFretboardScreenState
    extends State<InteractiveFretboardScreen> {
  static const _fretRanges = [12, 15, 18, 24];
  static const _fretboard = GuitarFretboard();

  late FretboardMode _mode;
  late SpelledPitchClass _root;
  late ChordQuality _chordQuality;
  late ScaleDefinition _scaleDefinition;
  FretboardDisplayMode _displayMode = FretboardDisplayMode.notes;
  int _maximumFret = 15;
  FretPosition? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialState.mode;
    _root = widget.initialState.root;
    _chordQuality = widget.initialState.chordQuality;
    _scaleDefinition = widget.initialState.scaleDefinition;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final projection = _mode == FretboardMode.chord
        ? FretboardProjection.chord(root: _root, quality: _chordQuality)
        : FretboardProjection.scale(root: _root, definition: _scaleDefinition);
    final positions = _fretboard.project(
      projection: projection,
      maximumFret: _maximumFret,
    );
    final selectionName = _mode == FretboardMode.chord
        ? '${_root.symbol}${_chordQuality.symbol}'
        : '${_root.symbol} ${localizations.scaleName(_scaleDefinition)}';

    return TunathicScaffold(
      title: localizations.interactiveFretboard,
      maxContentWidth: AppSpacing.pageMaxWidth,
      body: ListView(
        key: const Key('interactiveFretboardScroll'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.large,
          AppSpacing.medium,
          AppSpacing.xLarge,
        ),
        children: [
          Text(
            localizations.fretboardIntro,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.large),
          _buildPrimaryControls(localizations),
          const SizedBox(height: AppSpacing.large),
          PitchClassSelector(
            label: localizations.rootNoteLabel,
            choices: chromaticPitchClassChoices,
            selectedRoot: _root,
            keyPrefix: 'fretboardRoot',
            onSelected: (root) {
              setState(() {
                _root = root;
                _selectedPosition = null;
              });
            },
          ),
          const SizedBox(height: AppSpacing.large),
          _buildDefinitionSelector(localizations),
          const SizedBox(height: AppSpacing.large),
          Text(
            selectionName,
            key: const Key('fretboardSelectionName'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(localizations.fretboardOrientationHint),
          const SizedBox(height: AppSpacing.small),
          Text(
            localizations.tapHighlightedNoteHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.medium),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: AppRadii.mediumBorder,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.small),
              child: InteractiveFretboardView(
                positions: positions,
                maximumFret: _maximumFret,
                displayMode: _displayMode,
                semanticLabel: localizations.fretboardSemantics(
                  selectionName,
                  _maximumFret,
                  _root.symbol,
                ),
                onPositionSelected: (position) {
                  setState(() => _selectedPosition = position);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          _SelectedPositionDetails(position: _selectedPosition),
        ],
      ),
    );
  }

  Widget _buildPrimaryControls(AppLocalizations localizations) {
    final modeControl = _LabeledControl(
      label: localizations.fretboardModeLabel,
      child: SkeuoSegmentedControl<FretboardMode>(
        key: const Key('fretboardModeSelector'),
        segments: [
          SkeuoSegment(
            value: FretboardMode.chord,
            label: localizations.chordMode,
            icon: Icons.library_music_outlined,
          ),
          SkeuoSegment(
            value: FretboardMode.scale,
            label: localizations.scaleMode,
            icon: Icons.stacked_line_chart,
          ),
        ],
        selected: _mode,
        onChanged: (selection) {
          setState(() {
            _mode = selection;
            _selectedPosition = null;
          });
        },
      ),
    );
    final displayControl = _LabeledControl(
      label: localizations.displayModeLabel,
      child: SkeuoSegmentedControl<FretboardDisplayMode>(
        key: const Key('fretboardDisplayModeSelector'),
        segments: [
          SkeuoSegment(
            value: FretboardDisplayMode.notes,
            label: localizations.noteNames,
          ),
          SkeuoSegment(
            value: FretboardDisplayMode.degrees,
            label: localizations.degreesIntervals,
          ),
        ],
        selected: _displayMode,
        onChanged: (selection) {
          setState(() => _displayMode = selection);
        },
      ),
    );
    final fretControl = DropdownButtonFormField<int>(
      key: const Key('fretRangeSelector'),
      initialValue: _maximumFret,
      decoration: InputDecoration(labelText: localizations.visibleFretRange),
      items: [
        for (final fret in _fretRanges)
          DropdownMenuItem(
            value: fret,
            child: Text(localizations.fretRangeValue(fret)),
          ),
      ],
      onChanged: (fret) {
        if (fret == null) return;
        setState(() {
          _maximumFret = fret;
          _selectedPosition = null;
        });
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              modeControl,
              const SizedBox(height: AppSpacing.medium),
              displayControl,
              const SizedBox(height: AppSpacing.medium),
              fretControl,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: modeControl),
            const SizedBox(width: AppSpacing.large),
            Expanded(flex: 4, child: displayControl),
            const SizedBox(width: AppSpacing.large),
            Expanded(flex: 2, child: fretControl),
          ],
        );
      },
    );
  }

  Widget _buildDefinitionSelector(AppLocalizations localizations) {
    if (_mode == FretboardMode.chord) {
      return DropdownButtonFormField<ChordQuality>(
        key: const Key('fretboardChordQualitySelector'),
        initialValue: _chordQuality,
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
            _chordQuality = quality;
            _selectedPosition = null;
          });
        },
      );
    }
    return DropdownButtonFormField<ScaleDefinition>(
      key: const Key('fretboardScaleSelector'),
      initialValue: _scaleDefinition,
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
          _scaleDefinition = definition;
          _selectedPosition = null;
        });
      },
    );
  }
}

final class _LabeledControl extends StatelessWidget {
  const _LabeledControl({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.small),
        child,
      ],
    );
  }
}

final class _SelectedPositionDetails extends StatelessWidget {
  const _SelectedPositionDetails({required this.position});

  final FretPosition? position;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final current = position;
    if (current == null) return const SizedBox.shrink();
    final stringName = localizations.guitarStringNames[current.stringIndex];
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        key: const Key('selectedFretPosition'),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: AppRadii.mediumBorder,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  localizations.selectedPositionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.xLarge,
                runSpacing: AppSpacing.small,
                children: [
                  _Detail(
                    label: localizations.selectedNoteLabel,
                    value: '${current.displayedPitch!.symbol}${current.octave}',
                  ),
                  _Detail(
                    label: localizations.degreeIntervalLabel,
                    value: current.relationshipSymbol!,
                  ),
                  _Detail(label: localizations.stringLabel, value: stringName),
                  _Detail(
                    label: localizations.fretLabel,
                    value: '${current.fret}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
