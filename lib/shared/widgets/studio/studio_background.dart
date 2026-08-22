import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/studio_theme.dart';

/// The stage every studio screen stands on.
///
/// Static enamel grain, faint brushed lines, optional rack rails and a soft
/// vignette keep the warm surface from reading as one flat fill. Everything is
/// deterministic and painted once, so the texture costs nothing while pitch
/// detection runs.
final class StudioBackground extends StatelessWidget {
  const StudioBackground({
    required this.child,
    this.showSignalLines = false,
    super.key,
  });

  final Widget child;

  /// Draws the two rack rails and the waveform.
  ///
  /// Off by default. The rails sit at fixed fractions of the screen, which
  /// only frames anything on a layout that fills one screen — on the scrolling
  /// screens they ruled straight through whatever row happened to be at 18%,
  /// which read as a line struck through a section heading rather than as
  /// decoration behind it.
  ///
  /// The grain and vignette are not gated by this: they never collide with
  /// content, and dropping them would make a screen read as a different
  /// surface.
  final bool showSignalLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: TunathicSurfaces.studioBackground(context),
      child: CustomPaint(
        painter: _StudioStagePainter(
          accent: theme.colorScheme.primary,
          isDark: theme.brightness == Brightness.dark,
          showSignalLines: showSignalLines,
        ),
        isComplex: false,
        willChange: false,
        child: child,
      ),
    );
  }
}

/// Kept as its own widget because screens and tests refer to it by name.
final class SignalLineBackground extends StatelessWidget {
  const SignalLineBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      painter: _StudioStagePainter(
        accent: theme.colorScheme.primary,
        isDark: theme.brightness == Brightness.dark,
        showSignalLines: true,
      ),
      isComplex: false,
      willChange: false,
      child: child,
    );
  }
}

final class _StudioStagePainter extends CustomPainter {
  const _StudioStagePainter({
    required this.accent,
    required this.isDark,
    required this.showSignalLines,
  });

  final Color accent;
  final bool isDark;
  final bool showSignalLines;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    _paintEnamelGrain(canvas, size);
    _paintBrushedLines(canvas, size);
    if (showSignalLines) _paintSignalLines(canvas, size);
    _paintVignette(canvas, size);
  }

  void _paintEnamelGrain(Canvas canvas, Size size) {
    final area = size.width * size.height;
    final count = (area / 1800).round().clamp(80, 620);
    final dark = <Offset>[];
    final light = <Offset>[];
    var seed = 0x5EED1234;
    for (var index = 0; index < count; index++) {
      seed = (seed * 1664525 + 1013904223) & 0x7fffffff;
      final x = (seed / 0x7fffffff) * size.width;
      seed = (seed * 1664525 + 1013904223) & 0x7fffffff;
      final y = (seed / 0x7fffffff) * size.height;
      (index.isEven ? dark : light).add(Offset(x, y));
    }
    canvas.drawPoints(
      PointMode.points,
      dark,
      Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.055 : 0.025)
        ..strokeWidth = 0.7,
    );
    canvas.drawPoints(
      PointMode.points,
      light,
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.035 : 0.28)
        ..strokeWidth = 0.7,
    );
  }

  void _paintBrushedLines(Canvas canvas, Size size) {
    final dark = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.025 : 0.012)
      ..strokeWidth = 0.6;
    final light = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.025 : 0.18)
      ..strokeWidth = 0.6;
    for (var y = 11.0; y < size.height; y += 23) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), dark);
      canvas.drawLine(Offset(0, y + 1), Offset(size.width, y + 1), light);
    }
  }

  void _paintSignalLines(Canvas canvas, Size size) {
    final rail = Paint()
      ..color = accent.withValues(alpha: 0.25)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Two horizontal rules place the content between "rack rails".
    for (final fraction in const [0.18, 0.82]) {
      final y = size.height * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rail);
    }

    // One slow waveform across the lower third, clipped to whatever height the
    // screen actually has.
    final wave = Paint()
      ..color = accent.withValues(alpha: 0.12)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    final baseline = size.height * 0.82;
    final amplitude = math.min(size.height * 0.05, 26.0);
    const steps = 48;
    for (var step = 0; step <= steps; step++) {
      final x = size.width * step / steps;
      final y = baseline + math.sin(step / steps * math.pi * 4) * amplitude;
      if (step == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, wave);
  }

  /// Darkens the outer edges so the stage falls away behind the content.
  ///
  /// The system specifies this at 35% black. That is a dark-stage value: the
  /// light theme has no background-image override of its own, and 35% black
  /// over a work-light surface would read as a smudge, so light gets a trace
  /// of the same shape instead.
  void _paintVignette(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shader = RadialGradient(
      center: Alignment.topCenter,
      radius: 1.2,
      colors: [
        const Color(0x00000000),
        Color.fromRGBO(0, 0, 0, isDark ? 0.35 : 0.06),
      ],
      stops: const [0.4, 1],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_StudioStagePainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.isDark != isDark ||
      oldDelegate.showSignalLines != showSignalLines;
}
