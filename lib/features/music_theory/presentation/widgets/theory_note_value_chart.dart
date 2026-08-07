import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/features/music_theory/domain/theory_block.dart';
import 'package:tunathic/features/music_theory/domain/theory_content.dart';
import 'package:tunathic/l10n/app_localizations.dart';

/// Note durations drawn to scale against the longest value shown.
///
/// A dotted quarter being visibly one and a half times a quarter is the whole
/// point of the lesson, so the bars are measured rather than decorative.
final class TheoryNoteValueChartView extends StatelessWidget {
  const TheoryNoteValueChartView({
    required this.values,
    required this.content,
    super.key,
  });

  final List<TheoryNoteValue> values;
  final TheoryContent content;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final longest = values.fold<double>(
      0,
      (maximum, value) => value.beats > maximum ? value.beats : maximum,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final value in values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: Semantics(
              label:
                  '${content.text(value.nameId)}, ${value.symbol}, '
                  '${localizations.theoryBeatsValue(beatsLabel(context, value.beats))}',
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        value.symbol,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) => Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            height: 20,
                            width: longest == 0
                                ? 0
                                : constraints.maxWidth *
                                      (value.beats / longest),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              border: Border.all(color: colors.primary),
                              borderRadius: AppRadii.smallBorder,
                            ),
                            alignment: AlignmentDirectional.centerStart,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.small,
                            ),
                            child: Text(
                              content.text(value.nameId),
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: colors.onPrimaryContainer),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Thirds are written as fractions, because 0.33 beats reads as an error.
  /// Everything else is formatted for the reader's locale.
  @visibleForTesting
  static String beatsLabel(BuildContext context, double beats) {
    if (_isWhole(beats * 4)) {
      return NumberFormat.decimalPattern(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(beats);
    }
    return '${(beats * 3).round()}/3';
  }

  static bool _isWhole(double value) =>
      (value - value.roundToDouble()).abs() < 0.001;
}
