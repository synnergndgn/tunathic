import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/features/bpm_tap/domain/bpm_tap_engine.dart';
import 'package:tunathic/features/bpm_tap/presentation/bpm_tap_controller.dart';
import 'package:tunathic/l10n/app_localizations.dart';

final class BpmTapScreen extends ConsumerWidget {
  const BpmTapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(bpmTapProvider);
    final controller = ref.read(bpmTapProvider.notifier);
    final status = _status(localizations, state);
    final bpmText = state.bpm?.toString() ?? '—';

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.bpmTap),
        actions: [
          IconButton(
            key: const Key('bpmTapReset'),
            tooltip: localizations.reset,
            onPressed: state.tapCount == 0 ? null : controller.reset,
            icon: const Icon(Icons.restart_alt),
          ),
          const SizedBox(width: AppSpacing.small),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.small,
                AppSpacing.medium,
                AppSpacing.large,
              ),
              children: [
                Semantics(
                  liveRegion: true,
                  label: '${localizations.bpmLabel}: $bpmText',
                  child: ExcludeSemantics(
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            bpmText,
                            key: const Key('bpmValue'),
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  fontSize: 96,
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xSmall),
                        Text(
                          localizations.bpmLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: [
                    _MetricChip(
                      icon: Icons.touch_app_outlined,
                      label: localizations.tapCount(state.tapCount),
                    ),
                    _MetricChip(
                      icon: Icons.schedule_outlined,
                      label: state.lastInterval == null
                          ? localizations.noRecentInterval
                          : localizations.recentInterval(
                              state.lastInterval!.inMilliseconds,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    status,
                    key: const Key('bpmTapStatus'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Semantics(
                  button: true,
                  label: localizations.tapSurfaceSemantics(
                    status,
                    state.tapCount,
                    bpmText,
                  ),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: const Key('bpmTapSurface'),
                      onTap: controller.tap,
                      borderRadius: AppRadii.mediumBorder,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 220),
                        child: Center(
                          child: ExcludeSemantics(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.large),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.touch_app_outlined,
                                    size: 56,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(height: AppSpacing.medium),
                                  Text(
                                    state.tapCount == 0
                                        ? localizations.tapToBegin
                                        : localizations.keepTapping,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  localizations.bpmTapGuidance,
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

  String _status(AppLocalizations localizations, BpmTapState state) {
    if (state.lastEvent == BpmTapEvent.ignored) {
      return localizations.invalidTapIgnored;
    }
    if (state.lastEvent == BpmTapEvent.sessionReset) {
      return localizations.sessionReset;
    }
    if (state.tapCount == 0) return localizations.tapToBegin;
    if (state.bpm == null) return localizations.keepTapping;
    return localizations.bpmEstimateReady;
  }
}

final class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: AppRadii.smallBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.small),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
