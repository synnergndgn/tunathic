import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';

/// The detected note, printed as large as the display it was given allows.
///
/// The size is derived from the available width and then scaled down to fit,
/// so a 320 pt phone at double text scale shows the same layout as a tablet
/// rather than clipping or overflowing.
final class NoteReadout extends StatelessWidget {
  const NoteReadout({
    required this.noteName,
    required this.octave,
    required this.color,
    this.glow = 0,
    super.key,
  });

  /// Null while nothing is being detected; a dash is shown instead.
  final String? noteName;
  final int? octave;

  final Color color;

  /// Alpha of the halo behind the note. Only used to confirm a good reading.
  final double glow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSpacing.readingMaxWidth;
        final noteSize = (width * 0.32).clamp(56.0, 128.0);
        final octaveSize = noteSize * 0.34;

        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                noteName ?? '—',
                key: const Key('tunerDetectedNote'),
                maxLines: 1,
                style: TunathicTextStyles.heroNote(context, size: noteSize)
                    .copyWith(
                      color: color,
                      shadows: glow <= 0
                          ? null
                          : [
                              Shadow(
                                color: color.withValues(alpha: glow),
                                blurRadius: 28,
                              ),
                            ],
                    ),
              ),
              if (octave != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.xs,
                    bottom: noteSize * 0.12,
                  ),
                  child: Text(
                    octave.toString(),
                    key: const Key('tunerDetectedOctave'),
                    maxLines: 1,
                    style: TunathicTextStyles.tunerValue(
                      context,
                      size: octaveSize,
                    ).copyWith(color: color.withValues(alpha: 0.75)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
