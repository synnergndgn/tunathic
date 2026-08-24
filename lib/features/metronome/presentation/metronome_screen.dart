import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_motion.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/metronome/application/metronome_controller.dart';
import 'package:tunathic/features/metronome/domain/metronome_config.dart';
import 'package:tunathic/features/tools/tool_definition.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/control_dock.dart';
import 'package:tunathic/shared/widgets/studio/rack_panel.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/studio_state_panel.dart';
import 'package:tunathic/shared/widgets/studio/tunathic_scaffold.dart';

final class MetronomeScreen extends ConsumerStatefulWidget {
  const MetronomeScreen({super.key});

  @override
  ConsumerState<MetronomeScreen> createState() => _MetronomeScreenState();
}

final class _MetronomeScreenState extends ConsumerState<MetronomeScreen>
    with WidgetsBindingObserver {
  late final TextEditingController _tempoTextController;
  late final MetronomeController _metronomeController;
  final FocusNode _tempoFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _metronomeController = ref.read(metronomeProvider.notifier);
    final bpm = ref.read(metronomeProvider).config.bpm;
    _tempoTextController = TextEditingController(text: bpm.toString());
    WidgetsBinding.instance.addObserver(this);
    Future<void>.microtask(() {
      if (mounted) _metronomeController.prepareForScreen();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_metronomeController.handleLifecycle(isForeground: true));
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_metronomeController.handleLifecycle(isForeground: false));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tempoTextController.dispose();
    _tempoFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(metronomeProvider);
    final controller = _metronomeController;
    final haptics = ref.read(appHapticsProvider);
    final config = state.config;

    if (!_tempoFocusNode.hasFocus &&
        _tempoTextController.text != config.bpm.toString()) {
      _tempoTextController.text = config.bpm.toString();
    }

    return TunathicScaffold(
      title: localizations.metronome,
      showSignalLines: false,
      maxContentWidth: AppSpacing.readingMaxWidth,
      actions: [
        IconButton(
          key: const Key('metronomeReset'),
          tooltip: localizations.reset,
          onPressed: () {
            unawaited(haptics.selection());
            unawaited(controller.reset());
          },
          icon: const Icon(Icons.restart_alt),
        ),
      ],
      bottomDock: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.sm,
          AppSpacing.medium,
          AppSpacing.medium,
        ),
        child: ControlDock(
          children: [
            Semantics(
              button: true,
              label: state.isRunning
                  ? localizations.stopMetronome
                  : localizations.startMetronome,
              child: SkeuoButton(
                key: const Key('metronomeStartStop'),
                selected: state.isRunning,
                expand: true,
                onPressed: state.isInitializing
                    ? null
                    : () {
                        unawaited(haptics.lightImpact());
                        unawaited(controller.toggle());
                      },
                icon: state.isInitializing
                    ? null
                    : state.isRunning
                    ? Icons.stop
                    : Icons.play_arrow,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.isInitializing) ...[
                      const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        state.isInitializing
                            ? localizations.preparingAudio
                            : state.isRunning
                            ? localizations.stopMetronome
                            : localizations.startMetronome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // The dock is tight, so the switch shows the tool's short name
            // and keeps the full sentence for assistive tech.
            Semantics(
              button: true,
              label: localizations.openBpmTapForMetronome,
              child: SkeuoButton(
                key: const Key('openBpmTapFromMetronome'),
                icon: Icons.touch_app_outlined,
                expand: true,
                onPressed: () {
                  unawaited(haptics.selection());
                  unawaited(_openBpmTap(context, controller));
                },
                child: Text(
                  localizations.bpmTap,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        key: const Key('metronomeScroll'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.medium,
        ),
        children: [
          _TempoDisplay(state: state),
          const SizedBox(height: AppSpacing.md),
          RackPanel(
            label: localizations.tempo,
            labelIcon: Icons.speed_outlined,
            child: _TempoControls(
              state: state,
              textController: _tempoTextController,
              focusNode: _tempoFocusNode,
              onDecrement: controller.decrementBpm,
              onIncrement: controller.incrementBpm,
              onSubmitted: (value) {
                final bpm = int.tryParse(value);
                if (bpm != null) controller.setBpm(bpm);
                _tempoFocusNode.unfocus();
              },
              onSliderChanged: (value) => controller.previewBpm(value.round()),
              onSliderChangeEnd: (_) => controller.commitBpm(),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          RackPanel(
            label: localizations.timeSignature,
            labelIcon: Icons.grid_view_outlined,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final signature in MetronomeTimeSignature.values)
                  Semantics(
                    selected: config.timeSignature == signature,
                    button: true,
                    child: SkeuoButton(
                      key: Key('signature-${signature.id}'),
                      compact: true,
                      selected: config.timeSignature == signature,
                      onPressed: () {
                        unawaited(haptics.selection());
                        controller.setTimeSignature(signature);
                      },
                      child: Text(signature.id),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          RackPanel(
            label: localizations.sound,
            labelIcon: Icons.volume_up_outlined,
            child: Column(
              children: [
                RackRow(
                  label: localizations.accentFirstBeat,
                  value: SkeuoSwitch(
                    key: const Key('metronomeAccent'),
                    semanticLabel: localizations.accentFirstBeat,
                    value: config.accentEnabled,
                    onChanged: (enabled) {
                      unawaited(haptics.selection());
                      controller.setAccentEnabled(enabled);
                    },
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.volume_down_outlined),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Slider(
                        key: const Key('metronomeVolume'),
                        value: config.volume,
                        divisions: 20,
                        label: localizations.volumePercent(
                          (config.volume * 100).round(),
                        ),
                        semanticFormatterCallback: (_) => localizations
                            .volumePercent((config.volume * 100).round()),
                        onChanged: controller.previewVolume,
                        onChangeEnd: (_) => controller.commitVolume(),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text(
                        localizations.volumePercent(
                          (config.volume * 100).round(),
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TunathicTextStyles.metadata(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (state.failure != null) ...[
            const SizedBox(height: AppSpacing.medium),
            StudioStatePanel(
              icon: Icons.volume_off_outlined,
              title: localizations.audioUnavailableTitle,
              description: localizations.audioUnavailableDescription,
              actionLabel: localizations.retryAudio,
              onAction: () => unawaited(controller.start()),
              tone: StudioStateTone.problem,
            ),
          ],
          const SizedBox(height: AppSpacing.medium),
          Text(
            localizations.metronomeGuidance,
            textAlign: TextAlign.center,
            style: TunathicTextStyles.metadata(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openBpmTap(
    BuildContext context,
    MetronomeController controller,
  ) async {
    await controller.stop();
    if (!context.mounted) return;
    final bpm = await context.push<int>(
      AppRoutes.tool(ToolDefinition.bpmTap),
      extra: true,
    );
    if (!context.mounted || bpm == null) return;
    if (controller.applyBpmTap(bpm)) {
      unawaited(ref.read(appHapticsProvider).lightImpact());
      _tempoTextController.text = bpm.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).bpmTapApplied(bpm)),
        ),
      );
    }
  }
}

/// The tempo readout and the beat lamps, on one recessed display.
final class _TempoDisplay extends StatelessWidget {
  const _TempoDisplay({required this.state});

  final MetronomeState state;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final config = state.config;

    return DecoratedBox(
      decoration: TunathicSurfaces.tunerDisplay(
        context,
        signal: state.isRunning ? colors.primary : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            Semantics(
              container: true,
              label: localizations.tempoValue(config.bpm),
              child: ExcludeSemantics(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            config.bpm.toString(),
                            key: const Key('metronomeBpm'),
                            style:
                                TunathicTextStyles.heroNote(
                                  context,
                                  size: (constraints.maxWidth * 0.3).clamp(
                                    56.0,
                                    104.0,
                                  ),
                                ).copyWith(
                                  color: state.isRunning
                                      ? colors.primary
                                      : colors.onSurface,
                                ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: Text(
                              localizations.bpmLabel,
                              style: TunathicTextStyles.sectionTitle(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _runningStatus(localizations, state),
              key: const Key('metronomeStatus'),
              textAlign: TextAlign.center,
              style: TunathicTextStyles.metadata(context),
            ),
            const SizedBox(height: AppSpacing.medium),
            _BeatIndicators(state: state),
          ],
        ),
      ),
    );
  }

  String _runningStatus(AppLocalizations localizations, MetronomeState state) {
    if (state.isInitializing) return localizations.preparingAudio;
    if (!state.isRunning) return localizations.metronomeStopped;
    return localizations.currentBeatValue(
      state.currentBeat,
      state.config.timeSignature.beatsPerMeasure,
    );
  }
}

final class _TempoControls extends StatelessWidget {
  const _TempoControls({
    required this.state,
    required this.textController,
    required this.focusNode,
    required this.onDecrement,
    required this.onIncrement,
    required this.onSubmitted,
    required this.onSliderChanged,
    required this.onSliderChangeEnd,
  });

  final MetronomeState state;
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<double> onSliderChanged;
  final ValueChanged<double> onSliderChangeEnd;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final bpm = state.config.bpm;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              key: const Key('decrementTempo'),
              tooltip: localizations.decreaseTempo,
              onPressed: bpm <= MetronomeConfig.minimumBpm ? null : onDecrement,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 132),
                child: TextField(
                  key: const Key('tempoInput'),
                  controller: textController,
                  focusNode: focusNode,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    suffixText: localizations.bpmLabel,
                    border: const OutlineInputBorder(
                      borderRadius: AppRadii.mediumBorder,
                    ),
                  ),
                  onSubmitted: onSubmitted,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            IconButton.filledTonal(
              key: const Key('incrementTempo'),
              tooltip: localizations.increaseTempo,
              onPressed: bpm >= MetronomeConfig.maximumBpm ? null : onIncrement,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        Slider(
          key: const Key('tempoSlider'),
          value: bpm.toDouble(),
          min: MetronomeConfig.minimumBpm.toDouble(),
          max: MetronomeConfig.maximumBpm.toDouble(),
          divisions: MetronomeConfig.maximumBpm - MetronomeConfig.minimumBpm,
          label: localizations.tempoValue(bpm),
          semanticFormatterCallback: (_) => localizations.tempoValue(bpm),
          onChanged: onSliderChanged,
          onChangeEnd: onSliderChangeEnd,
        ),
      ],
    );
  }
}

final class _BeatIndicators extends StatelessWidget {
  const _BeatIndicators({required this.state});

  final MetronomeState state;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final config = state.config;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (var beat = 1; beat <= config.timeSignature.beatsPerMeasure; beat++)
          _BeatLamp(
            number: beat,
            isCurrent: state.isRunning && state.currentBeat == beat,
            isAccented: config.accentEnabled && beat == 1,
            semanticDetails: state.isRunning && state.currentBeat == beat
                ? config.accentEnabled && beat == 1
                      ? localizations.currentAccentedBeat
                      : localizations.currentBeatDetail
                : config.accentEnabled && beat == 1
                ? localizations.accentedBeat
                : localizations.inactiveBeat,
          ),
      ],
    );
  }
}

/// One beat, drawn as a lamp on the transport.
final class _BeatLamp extends StatelessWidget {
  const _BeatLamp({
    required this.number,
    required this.isCurrent,
    required this.isAccented,
    required this.semanticDetails,
  });

  final int number;
  final bool isCurrent;
  final bool isAccented;
  final String semanticDetails;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final studio = StudioTheme.of(context);
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final lampColor = isAccented ? colors.secondary : colors.primary;

    return Semantics(
      container: true,
      label: AppLocalizations.of(
        context,
      ).beatIndicatorSemantics(number, semanticDetails),
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: reducedMotion ? Duration.zero : AppMotion.fast,
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCurrent ? lampColor.withValues(alpha: 0.24) : studio.panel,
            borderRadius: AppRadii.mediumBorder,
            border: Border.all(
              color: isCurrent
                  ? lampColor
                  : isAccented
                  ? colors.secondary.withValues(alpha: 0.5)
                  : studio.panelBorder,
              width: isCurrent || isAccented ? 1.5 : 1,
            ),
          ),
          child: Text(
            number.toString(),
            style: TunathicTextStyles.compactLabel(context).copyWith(
              color: isCurrent ? lampColor : colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
