import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_colors.dart';

abstract final class AppTypography {
  /// The face every number in the app is set in.
  ///
  /// Readouts are instrument panel, not prose: a monospace stack keeps the
  /// note, the cents, the BPM and the frequency from reflowing as the digits
  /// change under someone's hand. Prose stays on the system sans.
  ///
  /// No font is bundled — each entry is resolved by the platform, and the
  /// generic `monospace` at the end is what Android actually lands on.
  static const tabularFamily = 'SF Mono';
  static const tabularFamilyFallback = <String>[
    'Consolas',
    'Menlo',
    'Roboto Mono',
    'Courier New',
    'monospace',
  ];

  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      // Panel headers and metadata are set in small caps so a rack row reads
      // as an engraved label rather than a paragraph heading.
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }
}

/// The named roles a studio screen prints text in.
///
/// Screens ask for a role instead of copying a font size, which is what keeps
/// the tuner, the metronome and the tap tempo readouts identical in weight.
abstract final class TunathicTextStyles {
  /// The single largest thing on screen: the detected note.
  ///
  /// Sized against the space it was given rather than a fixed constant, so a
  /// small phone and a tablet both fill their display without clipping.
  static TextStyle heroNote(BuildContext context, {double size = 96}) {
    return (Theme.of(context).textTheme.displayLarge ?? const TextStyle())
        .copyWith(
          fontFamily: AppTypography.tabularFamily,
          fontFamilyFallback: AppTypography.tabularFamilyFallback,
          fontSize: size,
          height: 0.95,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
  }

  /// A large numeric readout: cents, BPM, tap tempo.
  static TextStyle tunerValue(BuildContext context, {double size = 34}) {
    return (Theme.of(context).textTheme.headlineMedium ?? const TextStyle())
        .copyWith(
          fontFamily: AppTypography.tabularFamily,
          fontFamilyFallback: AppTypography.tabularFamilyFallback,
          fontSize: size,
          height: 1.05,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
  }

  /// The engraved label above a rack panel or a settings group.
  ///
  /// Set in the darkened orange accent, which is what makes a screen scan as a
  /// stack of engraved, labelled units while keeping small text accessible.
  static TextStyle sectionTitle(BuildContext context) {
    return (Theme.of(context).textTheme.labelSmall ?? const TextStyle())
        .copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.amber
              : AppColors.burntOrange,
        );
  }

  /// A label inside a control: dock item, preset chip, meter end.
  static TextStyle compactLabel(BuildContext context) {
    return (Theme.of(context).textTheme.labelLarge ?? const TextStyle())
        .copyWith(height: 1.15);
  }

  /// Supporting prose: a tool's one-line description, a settings hint, a
  /// version string.
  ///
  /// Stays on the system sans. Only numbers go monospace — running this role
  /// through the tabular stack sets whole Turkish sentences in Courier.
  static TextStyle metadata(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
        .copyWith(
          color: colors.onSurfaceVariant,
          height: 1.3,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
  }

  /// A small engraved number: measured frequency, reference pitch, a tag.
  ///
  /// The monospace counterpart to [metadata] — same size and colour, so the
  /// two sit together on a line without one looking bigger than the other.
  static TextStyle readout(BuildContext context) {
    return metadata(context).copyWith(
      fontFamily: AppTypography.tabularFamily,
      fontFamilyFallback: AppTypography.tabularFamilyFallback,
    );
  }
}
