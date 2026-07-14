import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/metronome/application/metronome_controller.dart';
import 'package:tunathic/features/metronome/domain/metronome_config.dart';
import 'package:tunathic/features/tools/tool_definition.dart';
import 'package:tunathic/l10n/app_localizations.dart';

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
    _metronomeController.prepareForScreen();
    final bpm = ref.read(metronomeProvider).config.bpm;
    _tempoTextController = TextEditingController(text: bpm.toString());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(
      _metronomeController.handleLifecycle(
        isForeground: state == AppLifecycleState.resumed,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_metronomeController.releaseAudio());
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

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.metronome),
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
          const SizedBox(width: AppSpacing.small),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              key: const Key('metronomeScroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.small,
                AppSpacing.medium,
                AppSpacing.large,
              ),
              children: [
                Semantics(
                  label: localizations.tempoValue(config.bpm),
                  child: ExcludeSemantics(
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            config.bpm.toString(),
                            key: const Key('metronomeBpm'),
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  fontSize: 88,
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xSmall),
                        Text(
                          localizations.beatsPerMinute,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                _TempoControls(
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
                  onSliderChanged: (value) =>
                      controller.previewBpm(value.round()),
                  onSliderChangeEnd: (_) => controller.commitBpm(),
                ),
                const SizedBox(height: AppSpacing.medium),
                _SectionCard(
                  title: localizations.currentBeat,
                  child: Column(
                    children: [
                      Text(
                        _runningStatus(localizations, state),
                        key: const Key('metronomeStatus'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      _BeatIndicators(state: state),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                _SectionCard(
                  title: localizations.timeSignature,
                  child: Wrap(
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.small,
                    children: [
                      for (final signature in MetronomeTimeSignature.values)
                        Semantics(
                          selected: config.timeSignature == signature,
                          button: true,
                          child: ChoiceChip(
                            key: Key('signature-${signature.id}'),
                            label: Text(signature.id),
                            selected: config.timeSignature == signature,
                            onSelected: (_) {
                              unawaited(haptics.selection());
                              controller.setTimeSignature(signature);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                _SectionCard(
                  title: localizations.sound,
                  child: Column(
                    children: [
                      SwitchListTile(
                        key: const Key('metronomeAccent'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(localizations.accentFirstBeat),
                        value: config.accentEnabled,
                        onChanged: (enabled) {
                          unawaited(haptics.selection());
                          controller.setAccentEnabled(enabled);
                        },
                      ),
                      Row(
                        children: [
                          const Icon(Icons.volume_down_outlined),
                          const SizedBox(width: AppSpacing.small),
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
                            width: 52,
                            child: Text(
                              localizations.volumePercent(
                                (config.volume * 100).round(),
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (state.failure != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  _AudioErrorCard(onRetry: () => unawaited(controller.start())),
                ],
                const SizedBox(height: AppSpacing.large),
                Semantics(
                  button: true,
                  label: state.isRunning
                      ? localizations.stopMetronome
                      : localizations.startMetronome,
                  child: FilledButton.icon(
                    key: const Key('metronomeStartStop'),
                    onPressed: state.isInitializing
                        ? null
                        : () {
                            unawaited(haptics.lightImpact());
                            unawaited(controller.toggle());
                          },
                    icon: state.isInitializing
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(state.isRunning ? Icons.stop : Icons.play_arrow),
                    label: Text(
                      state.isInitializing
                          ? localizations.preparingAudio
                          : state.isRunning
                          ? localizations.stopMetronome
                          : localizations.startMetronome,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                OutlinedButton.icon(
                  key: const Key('openBpmTapFromMetronome'),
                  onPressed: () {
                    unawaited(haptics.selection());
                    unawaited(_openBpmTap(context, controller));
                  },
                  icon: const Icon(Icons.touch_app_outlined),
                  label: Text(localizations.openBpmTapForMetronome),
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  localizations.metronomeGuidance,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
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
    return _SectionCard(
      title: localizations.tempo,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                key: const Key('decrementTempo'),
                tooltip: localizations.decreaseTempo,
                onPressed: bpm <= MetronomeConfig.minimumBpm
                    ? null
                    : onDecrement,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: AppSpacing.medium),
              SizedBox(
                width: 112,
                child: TextField(
                  key: const Key('tempoInput'),
                  controller: textController,
                  focusNode: focusNode,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: localizations.tempo,
                    suffixText: localizations.bpmLabel,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: onSubmitted,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              IconButton.filledTonal(
                key: const Key('incrementTempo'),
                tooltip: localizations.increaseTempo,
                onPressed: bpm >= MetronomeConfig.maximumBpm
                    ? null
                    : onIncrement,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
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
      ),
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
      spacing: AppSpacing.small,
      runSpacing: AppSpacing.small,
      children: [
        for (var beat = 1; beat <= config.timeSignature.beatsPerMeasure; beat++)
          _BeatIndicator(
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

final class _BeatIndicator extends StatelessWidget {
  const _BeatIndicator({
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
    return Semantics(
      label: AppLocalizations.of(
        context,
      ).beatIndicatorSemantics(number, semanticDetails),
      child: ExcludeSemantics(
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCurrent ? colors.primary : colors.surfaceContainerHighest,
            borderRadius: AppRadii.smallBorder,
            border: Border.all(
              color: isAccented ? colors.secondary : colors.outlineVariant,
              width: isAccented ? 2 : 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                number.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isCurrent ? colors.onPrimary : colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isAccented)
                Positioned(
                  top: 0,
                  right: 2,
                  child: Icon(
                    Icons.expand_more,
                    size: 16,
                    color: isCurrent ? colors.onPrimary : colors.secondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.medium),
            child,
          ],
        ),
      ),
    );
  }
}

final class _AudioErrorCard extends StatelessWidget {
  const _AudioErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      child: Card(
        color: colors.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.audioUnavailableTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onErrorContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                localizations.audioUnavailableDescription,
                style: TextStyle(color: colors.onErrorContainer),
              ),
              const SizedBox(height: AppSpacing.small),
              TextButton(
                onPressed: onRetry,
                child: Text(localizations.retryAudio),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
