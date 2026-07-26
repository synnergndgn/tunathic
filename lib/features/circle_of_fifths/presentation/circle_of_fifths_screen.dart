import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/chord_library/domain/chord_library_route_state.dart';
import 'package:tunathic/features/circle_of_fifths/presentation/circle_of_fifths_localizations.dart';
import 'package:tunathic/features/circle_of_fifths/presentation/circle_of_fifths_view.dart';
import 'package:tunathic/features/fretboard/domain/fretboard_route_state.dart';
import 'package:tunathic/features/scale_library/domain/scale_library_route_state.dart';
import 'package:tunathic/l10n/app_localizations.dart';

final class CircleOfFifthsScreen extends StatefulWidget {
  const CircleOfFifthsScreen({super.key});

  @override
  State<CircleOfFifthsScreen> createState() => _CircleOfFifthsScreenState();
}

final class _CircleOfFifthsScreenState extends State<CircleOfFifthsScreen> {
  MusicalKey _selectedKey = CircleOfFifths.positions.first.major;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final harmony = DiatonicHarmonyConstructor.construct(_selectedKey);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.circleOfFifths)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.pageMaxWidth,
            ),
            child: ListView(
              key: const Key('circleOfFifthsScroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.large,
                AppSpacing.medium,
                AppSpacing.xLarge,
              ),
              children: [
                Text(
                  localizations.circleOfFifthsIntro,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  localizations.circleOrientationHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.large),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final circle = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _CircleLegend(),
                        const SizedBox(height: AppSpacing.small),
                        CircleOfFifthsView(
                          selectedKey: _selectedKey,
                          onSelected: _selectKey,
                        ),
                      ],
                    );
                    final details = _KeyDetails(
                      key: const Key('circleKeyDetails'),
                      selectedKey: _selectedKey,
                      harmony: harmony,
                      onSelectKey: _selectKey,
                      onViewScale: _viewScale,
                      onViewFretboard: _viewFretboard,
                      onOpenChord: _openChord,
                    );
                    if (constraints.maxWidth < 840) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          circle,
                          const SizedBox(height: AppSpacing.xLarge),
                          details,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 10, child: circle),
                        const SizedBox(width: AppSpacing.xLarge),
                        Expanded(flex: 11, child: details),
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

  void _selectKey(MusicalKey key) {
    setState(() => _selectedKey = key);
  }

  void _viewScale() {
    context.push(
      AppRoutes.scaleLibrary(
        ScaleLibraryRouteState(
          root: _selectedKey.tonic,
          definition: _selectedKey.scaleDefinition,
        ),
      ),
    );
  }

  void _viewFretboard() {
    context.push(
      AppRoutes.fretboard(
        FretboardRouteState(
          mode: FretboardMode.scale,
          root: _selectedKey.tonic,
          scaleDefinition: _selectedKey.scaleDefinition,
        ),
      ),
    );
  }

  void _openChord(DiatonicChord entry) {
    context.push(
      AppRoutes.chordLibrary(
        ChordLibraryRouteState(
          root: entry.chord.root,
          quality: entry.chord.quality,
        ),
      ),
    );
  }
}

final class _CircleLegend extends StatelessWidget {
  const _CircleLegend();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.large,
      runSpacing: AppSpacing.small,
      children: [
        _LegendItem(shape: BoxShape.rectangle, label: localizations.keyMajor),
        _LegendItem(shape: BoxShape.circle, label: localizations.keyMinor),
      ],
    );
  }
}

final class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.shape, required this.label});

  final BoxShape shape;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: shape,
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        Text(label),
      ],
    );
  }
}

final class _KeyDetails extends StatelessWidget {
  const _KeyDetails({
    required this.selectedKey,
    required this.harmony,
    required this.onSelectKey,
    required this.onViewScale,
    required this.onViewFretboard,
    required this.onOpenChord,
    super.key,
  });

  final MusicalKey selectedKey;
  final DiatonicHarmony harmony;
  final ValueChanged<MusicalKey> onSelectKey;
  final VoidCallback onViewScale;
  final VoidCallback onViewFretboard;
  final ValueChanged<DiatonicChord> onOpenChord;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final parallel = selectedKey.parallelKey;
    final position = CircleOfFifths.positionFor(selectedKey);
    final enharmonic = _enharmonicAlternative(position);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            localizations.keyName(selectedKey),
            key: const Key('selectedKeyName'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        if (enharmonic != null) ...[
          const SizedBox(height: AppSpacing.small),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ActionChip(
              key: const Key('enharmonicKeyAction'),
              avatar: const Icon(Icons.swap_horiz, size: 18),
              label: Text(
                '${localizations.enharmonicEquivalentLabel}: '
                '${localizations.keyName(enharmonic)}',
              ),
              onPressed: () => onSelectKey(enharmonic),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.medium),
        _KeySignatureCard(keyValue: selectedKey),
        const SizedBox(height: AppSpacing.medium),
        _RelationshipsCard(
          selectedKey: selectedKey,
          parallel: parallel,
          onSelectKey: onSelectKey,
        ),
        const SizedBox(height: AppSpacing.medium),
        _ScaleCard(harmony: harmony),
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            FilledButton.icon(
              key: const Key('circleViewScale'),
              onPressed: onViewScale,
              icon: const Icon(Icons.stacked_line_chart),
              label: Text(localizations.viewScale),
            ),
            OutlinedButton.icon(
              key: const Key('circleViewFretboard'),
              onPressed: onViewFretboard,
              icon: const Icon(Icons.grid_on_outlined),
              label: Text(localizations.viewOnFretboard),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xLarge),
        Semantics(
          header: true,
          child: Text(
            localizations.diatonicChordsLabel,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.xSmall),
        Text(localizations.tapChordHint),
        const SizedBox(height: AppSpacing.medium),
        _DiatonicChordList(
          title: localizations.triadsLabel,
          entries: harmony.triads,
          keyPrefix: 'triad',
          onOpenChord: onOpenChord,
        ),
        const SizedBox(height: AppSpacing.large),
        _DiatonicChordList(
          title: localizations.seventhChordsLabel,
          entries: harmony.seventhChords,
          keyPrefix: 'seventh',
          onOpenChord: onOpenChord,
        ),
      ],
    );
  }

  MusicalKey? _enharmonicAlternative(CirclePosition position) {
    final candidates = selectedKey.tonality == KeyTonality.major
        ? position.majorKeys
        : position.minorKeys;
    for (final candidate in candidates) {
      if (candidate.tonic != selectedKey.tonic) return candidate;
    }
    return null;
  }
}

final class _KeySignatureCard extends StatelessWidget {
  const _KeySignatureCard({required this.keyValue});

  final MusicalKey keyValue;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final signature = keyValue.keySignature;
    final description = localizations.keySignatureDescription(signature);
    final notes = signature.alteredNotes.map((note) => note.symbol).join(' · ');
    final spokenNotes = signature.alteredNotes.isEmpty
        ? localizations.noSharpsOrFlats
        : signature.alteredNotes.map((note) => note.symbol).join(', ');

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: localizations.keySignatureSemantics(description, spokenNotes),
      child: Card(
        key: const Key('keySignatureCard'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  localizations.keySignatureLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  description,
                  key: const Key('keySignatureDescription'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    localizations.alteredNotesLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    notes,
                    key: const Key('alteredNotes'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _RelationshipsCard extends StatelessWidget {
  const _RelationshipsCard({
    required this.selectedKey,
    required this.parallel,
    required this.onSelectKey,
  });

  final MusicalKey selectedKey;
  final MusicalKey? parallel;
  final ValueChanged<MusicalKey> onSelectKey;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final relative = selectedKey.relativeKey;
    final fifth = CircleOfFifths.clockwiseNeighbor(selectedKey);
    final fourth = CircleOfFifths.counterClockwiseNeighbor(selectedKey);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            _RelationshipChip(
              key: const Key('relativeKey'),
              label: localizations.relativeLabel(selectedKey.tonality),
              value: localizations.keyName(relative),
              icon: Icons.link,
              onPressed: () => onSelectKey(relative),
            ),
            _RelationshipChip(
              key: const Key('parallelKey'),
              label: localizations.parallelLabel(selectedKey.tonality),
              value: parallel == null
                  ? localizations.relationshipUnavailable
                  : localizations.keyName(parallel!),
              icon: Icons.compare_arrows,
              onPressed: parallel == null ? null : () => onSelectKey(parallel!),
            ),
            _RelationshipChip(
              key: const Key('fifthNeighbor'),
              label: localizations.fifthNeighborLabel,
              value: localizations.keyName(fifth),
              icon: Icons.arrow_forward,
              onPressed: () => onSelectKey(fifth),
            ),
            _RelationshipChip(
              key: const Key('fourthNeighbor'),
              label: localizations.fourthNeighborLabel,
              value: localizations.keyName(fourth),
              icon: Icons.arrow_back,
              onPressed: () => onSelectKey(fourth),
            ),
          ],
        ),
      ),
    );
  }
}

final class _RelationshipChip extends StatelessWidget {
  const _RelationshipChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label\n',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            TextSpan(
              text: value,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
      onPressed: onPressed,
    );
  }
}

final class _ScaleCard extends StatelessWidget {
  const _ScaleCard({required this.harmony});

  final DiatonicHarmony harmony;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              localizations.scaleNotesLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.small),
            Wrap(
              key: const Key('keyScaleNotes'),
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                for (final tone in harmony.scale.tones)
                  Chip(label: Text(tone.symbol)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _DiatonicChordList extends StatelessWidget {
  const _DiatonicChordList({
    required this.title,
    required this.entries,
    required this.keyPrefix,
    required this.onOpenChord,
  });

  final String title;
  final List<DiatonicChord> entries;
  final String keyPrefix;
  final ValueChanged<DiatonicChord> onOpenChord;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: AppSpacing.small),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 560
                ? 4
                : constraints.maxWidth >= 360
                ? 3
                : 2;
            final gaps = AppSpacing.small * (columns - 1);
            final width = (constraints.maxWidth - gaps) / columns;
            return Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                for (final entry in entries)
                  SizedBox(
                    width: width,
                    child: _DiatonicChordCard(
                      key: Key('$keyPrefix-${entry.degree}'),
                      entry: entry,
                      onTap: () => onOpenChord(entry),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

final class _DiatonicChordCard extends StatelessWidget {
  const _DiatonicChordCard({
    required this.entry,
    required this.onTap,
    super.key,
  });

  final DiatonicChord entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Semantics(
      container: true,
      button: true,
      excludeSemantics: true,
      label: localizations.diatonicChordSemantics(
        entry.romanNumeral.symbol,
        entry.chord.symbol,
      ),
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.smallBorder,
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.small),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.romanNumeral.symbol,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(
                    entry.chord.symbol,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
