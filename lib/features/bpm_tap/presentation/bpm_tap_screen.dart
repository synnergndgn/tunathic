import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/bpm_tap/domain/bpm_tap_engine.dart';
import 'package:tunathic/features/bpm_tap/presentation/bpm_tap_controller.dart';
import 'package:tunathic/shared/widgets/studio/frequency_readout.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/control_dock.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/tunathic_scaffold.dart';

final class BpmTapScreen extends ConsumerWidget {
  const BpmTapScreen({this.allowApplyResult = false, super.key});

  final bool allowApplyResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(bpmTapProvider);
    final controller = ref.read(bpmTapProvider.notifier);
    final haptics = ref.read(appHapticsProvider);
    final status = _status(localizations, state);
    final bpmText = state.bpm?.toString() ?? '—';

    return TunathicScaffold(
      title: localizations.bpmTap,
      showSignalLines: false,
      maxContentWidth: AppSpacing.readingMaxWidth,
      actions: [
        IconButton(
          key: const Key('bpmTapReset'),
          tooltip: localizations.reset,
          onPressed: state.tapCount == 0
              ? null
              : () {
                  unawaited(haptics.selection());
                  controller.reset();
                },
          icon: const Icon(Icons.restart_alt),
        ),
      ],
      bottomDock: allowApplyResult
          ? Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.sm,
                AppSpacing.medium,
                AppSpacing.medium,
              ),
              child: ControlDock(
                children: [
                  SkeuoButton(
                    key: const Key('applyBpmTapResult'),
                    selected: true,
                    expand: true,
                    icon: Icons.check,
                    onPressed: state.bpm == null
                        ? null
                        : () {
                            unawaited(haptics.lightImpact());
                            context.pop(state.bpm);
                          },
                    child: Text(
                      localizations.applyBpmTapResult,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: ListView(
        key: const Key('bpmTapScroll'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.medium,
        ),
        children: [
          _TapDisplay(bpmText: bpmText, status: status, state: state),
          const SizedBox(height: AppSpacing.md),
          _TapPad(
            tapCount: state.tapCount,
            semanticsLabel: localizations.tapSurfaceSemantics(
              status,
              state.tapCount,
              bpmText,
            ),
            label: state.tapCount == 0
                ? localizations.tapToBegin
                : localizations.keepTapping,
            onTap: () {
              unawaited(haptics.lightImpact());
              controller.tap();
            },
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            localizations.bpmTapGuidance,
            textAlign: TextAlign.center,
            style: TunathicTextStyles.metadata(context),
          ),
        ],
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

/// The tempo readout, with tap count and last interval beside it.
final class _TapDisplay extends StatelessWidget {
  const _TapDisplay({
    required this.bpmText,
    required this.status,
    required this.state,
  });

  final String bpmText;
  final String status;
  final BpmTapState state;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: TunathicSurfaces.tunerDisplay(
        context,
        signal: state.bpm == null ? null : colors.primary,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            Semantics(
              container: true,
              liveRegion: true,
              label: '${localizations.bpmLabel}: $bpmText',
              child: ExcludeSemantics(
                child: LayoutBuilder(
                  builder: (context, constraints) => FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          bpmText,
                          key: const Key('bpmValue'),
                          style:
                              TunathicTextStyles.heroNote(
                                context,
                                size: (constraints.maxWidth * 0.3).clamp(
                                  56.0,
                                  104.0,
                                ),
                              ).copyWith(
                                color: state.bpm == null
                                    ? colors.onSurface
                                    : colors.primary,
                              ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Text(
                            localizations.bpmLabel,
                            style: TunathicTextStyles.sectionTitle(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              container: true,
              liveRegion: true,
              child: Text(
                status,
                key: const Key('bpmTapStatus'),
                textAlign: TextAlign.center,
                style: TunathicTextStyles.metadata(context),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FrequencyReadout(
                  label: localizations.tapCount(state.tapCount),
                  value: localizations.tapCount(state.tapCount),
                  icon: Icons.touch_app_outlined,
                ),
                FrequencyReadout(
                  label: state.lastInterval == null
                      ? localizations.noRecentInterval
                      : localizations.recentInterval(
                          state.lastInterval!.inMilliseconds,
                        ),
                  value: state.lastInterval == null
                      ? localizations.noRecentInterval
                      : localizations.recentInterval(
                          state.lastInterval!.inMilliseconds,
                        ),
                  icon: Icons.schedule_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The surface the tempo is tapped on: one large, unmistakable target.
final class _TapPad extends StatelessWidget {
  const _TapPad({
    required this.tapCount,
    required this.semanticsLabel,
    required this.label,
    required this.onTap,
  });

  final int tapCount;
  final String semanticsLabel;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final studio = StudioTheme.of(context);

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: const Key('bpmTapSurface'),
            onTap: onTap,
            borderRadius: AppRadii.deviceBorder,
            child: Ink(
              decoration: BoxDecoration(
                color: studio.panelRaised,
                borderRadius: AppRadii.deviceBorder,
                border: Border.all(
                  color: tapCount == 0
                      ? studio.panelBorderStrong
                      : colors.primary.withValues(alpha: 0.55),
                  width: 1.5,
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 200),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 48,
                          color: colors.primary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
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
    );
  }
}
