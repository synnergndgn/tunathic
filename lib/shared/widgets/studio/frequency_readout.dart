import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

/// A small engraved readout for supporting numbers.
///
/// Used for the measured frequency and for the fixed A4 reference. Both are
/// deliberately quieter than the note itself: they confirm a reading, they are
/// not what someone tunes by.
final class FrequencyReadout extends StatelessWidget {
  const FrequencyReadout({
    required this.label,
    required this.value,
    this.valueKey,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final Key? valueKey;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: label,
      child: ExcludeSemantics(child: _readout(context)),
    );
  }

  Widget _readout(BuildContext context) {
    // The chip carries a measured value most of the time, but the tuner also
    // parks a sentence in it while it waits ("Waiting for a string"). Only
    // numbers earn the tabular face; a sentence set in Courier reads as a
    // glitch rather than as an instrument.
    final hasNumber = RegExp(r'\d').hasMatch(value);
    final metadata = hasNumber
        ? TunathicTextStyles.readout(context)
        : TunathicTextStyles.metadata(context);
    return SkeuoDisplayPanel(
      radius: const Radius.circular(4),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: metadata.color),
            const SizedBox(width: AppSpacing.xs + 2),
          ],
          Flexible(
            child: Text(
              value,
              key: valueKey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: metadata.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
