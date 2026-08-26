abstract final class AppSpacing {
  static const xSmall = 4.0;
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const xLarge = 32.0;
  static const xxLarge = 48.0;

  /// The studio scale. [md] is the only new step: it is the gap that keeps
  /// stacked device rows tight without letting them touch.
  static const xs = xSmall;
  static const sm = small;
  static const md = 12.0;
  static const lg = medium;
  static const xl = large;
  static const xxl = xLarge;

  static const pageMaxWidth = 1200.0;
  static const contentMaxWidth = 760.0;
  static const readingMaxWidth = 680.0;
  static const minTouchTarget = 48.0;
}

/// Discoverable alias so new code can spell the product name.
typedef TunathicSpacing = AppSpacing;
