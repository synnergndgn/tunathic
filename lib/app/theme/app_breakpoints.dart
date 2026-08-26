import 'package:flutter/widgets.dart';

/// Width classes used across Tunathic.
///
/// Layouts branch on the width they were actually given rather than on the
/// window, so a panel nested inside a two-column screen still picks the right
/// arrangement.
enum TunathicWidthClass { compact, medium, expanded }

abstract final class TunathicBreakpoints {
  /// Phones in portrait.
  static const compact = 600.0;

  /// Large phones in landscape, small tablets, split-screen.
  static const medium = 840.0;

  /// Tablets and desktop-sized windows: wide enough for a side panel.
  static const expanded = 1200.0;

  static TunathicWidthClass classify(double width) {
    if (width >= medium) return TunathicWidthClass.expanded;
    if (width >= compact) return TunathicWidthClass.medium;
    return TunathicWidthClass.compact;
  }

  static TunathicWidthClass of(BuildContext context) =>
      classify(MediaQuery.sizeOf(context).width);

  /// True when the viewport is both wide enough and tall enough to show the
  /// tuner display beside its controls instead of above them.
  static bool allowsSidePanel(BoxConstraints constraints) =>
      constraints.maxWidth >= medium && constraints.maxHeight >= 480;
}
