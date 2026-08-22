import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_motion.dart';

/// Swaps one readout for another without a jump.
///
/// Short and cheap on purpose: the tuner changes state several times a second
/// while someone is tuning, and anything longer would smear rather than
/// clarify. Honours the platform's reduce-motion setting.
final class AnimatedSignalTransition extends StatelessWidget {
  const AnimatedSignalTransition({
    required this.child,
    this.duration = AppMotion.fast,
    super.key,
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AppMotion.standardCurve,
      switchOutCurve: AppMotion.standardCurve,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
