import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_motion.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

/// Compatibility name used by the tuner screen.
///
/// The implementation is the physical [SkeuoAnalogMeter], not a Material
/// progress bar.
final class PitchMeter extends StatelessWidget {
  const PitchMeter({
    required this.cents,
    required this.signal,
    required this.semanticsLabel,
    required this.flatLabel,
    required this.inTuneLabel,
    required this.sharpLabel,
    this.visualRangeCents = 50,
    super.key,
  });

  final double? cents;
  final StudioSignal signal;
  final String semanticsLabel;
  final String flatLabel;
  final String inTuneLabel;
  final String sharpLabel;
  final double visualRangeCents;

  @override
  Widget build(BuildContext context) {
    return SkeuoAnalogMeter(
      cents: cents,
      signal: signal,
      semanticsLabel: semanticsLabel,
      flatLabel: flatLabel,
      inTuneLabel: inTuneLabel,
      sharpLabel: sharpLabel,
      visualRangeCents: visualRangeCents,
    );
  }
}

/// A semicircular tuner movement with a shadowed needle and metal pivot.
final class SkeuoAnalogMeter extends StatelessWidget {
  const SkeuoAnalogMeter({
    required this.cents,
    required this.signal,
    required this.semanticsLabel,
    required this.flatLabel,
    required this.inTuneLabel,
    required this.sharpLabel,
    this.visualRangeCents = 50,
    super.key,
  });

  final double? cents;
  final StudioSignal signal;
  final String semanticsLabel;
  final String flatLabel;
  final String inTuneLabel;
  final String sharpLabel;
  final double visualRangeCents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studio = StudioTheme.of(context);
    final reading = cents;
    final normalized = ((reading ?? 0) / visualRangeCents).clamp(-1.0, 1.0);
    final needleColor = studio.signalColor(signal);

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: SkeuoInsetPanel(
          radius: const Radius.circular(5),
          surfaceColor: Color.alphaBlend(
            theme.colorScheme.surface.withValues(alpha: 0.26),
            studio.display,
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.hasBoundedWidth
                  ? constraints.maxWidth
                  : 320.0;
              final height = (width * 0.55).clamp(150.0, 210.0);
              return SizedBox(
                height: height,
                width: width,
                child: Column(
                  children: [
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: normalized, end: normalized),
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : AppMotion.standard,
                        curve: AppMotion.standardCurve,
                        builder: (context, value, _) => CustomPaint(
                          painter: _AnalogDialPainter(
                            normalized: value,
                            hasReading: reading != null,
                            needleColor: needleColor,
                            ink: theme.colorScheme.onSurface,
                            mutedInk: theme.colorScheme.onSurfaceVariant,
                            grid: studio.gridLine,
                            centre: studio.inTune,
                            flatLabel: flatLabel,
                            inTuneLabel: inTuneLabel,
                            sharpLabel: sharpLabel,
                            isDark: theme.brightness == Brightness.dark,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _MeterLegend(
                      signal: signal,
                      flatLabel: flatLabel,
                      inTuneLabel: inTuneLabel,
                      sharpLabel: sharpLabel,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

final class _MeterLegend extends StatelessWidget {
  const _MeterLegend({
    required this.signal,
    required this.flatLabel,
    required this.inTuneLabel,
    required this.sharpLabel,
  });

  final StudioSignal signal;
  final String flatLabel;
  final String inTuneLabel;
  final String sharpLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studio = StudioTheme.of(context);

    Widget label(String text, StudioSignal owner, TextAlign align) {
      final active = signal == owner;
      return Expanded(
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: theme.textTheme.labelSmall?.copyWith(
            color: active
                ? studio.signalColor(owner)
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: active ? FontWeight.w900 : FontWeight.w700,
            letterSpacing: 0.25,
          ),
        ),
      );
    }

    return Row(
      children: [
        label(flatLabel, StudioSignal.flat, TextAlign.start),
        const SizedBox(width: AppSpacing.xs),
        label(inTuneLabel, StudioSignal.inTune, TextAlign.center),
        const SizedBox(width: AppSpacing.xs),
        label(sharpLabel, StudioSignal.sharp, TextAlign.end),
      ],
    );
  }
}

final class _AnalogDialPainter extends CustomPainter {
  const _AnalogDialPainter({
    required this.normalized,
    required this.hasReading,
    required this.needleColor,
    required this.ink,
    required this.mutedInk,
    required this.grid,
    required this.centre,
    required this.flatLabel,
    required this.inTuneLabel,
    required this.sharpLabel,
    required this.isDark,
  });

  final double normalized;
  final bool hasReading;
  final Color needleColor;
  final Color ink;
  final Color mutedInk;
  final Color grid;
  final Color centre;
  final String flatLabel;
  final String inTuneLabel;
  final String sharpLabel;
  final bool isDark;

  static const _startAngle = math.pi * 1.10;
  static const _sweepAngle = math.pi * 0.80;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final pivot = Offset(size.width / 2, size.height * 0.83);
    final radius = math.min(size.width * 0.43, size.height * 0.70);
    final arcRect = Rect.fromCircle(center: pivot, radius: radius);

    _paintDialFace(canvas, arcRect);
    _paintArcs(canvas, arcRect);
    _paintTicks(canvas, pivot, radius);
    _paintNeedle(canvas, pivot, radius);
    _paintPivot(canvas, pivot, size);
  }

  void _paintDialFace(Canvas canvas, Rect arcRect) {
    final face = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        center: const Alignment(0, 0.7),
        radius: 1.05,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.035 : 0.30),
          Colors.transparent,
          Colors.black.withValues(alpha: isDark ? 0.12 : 0.045),
        ],
      ).createShader(arcRect);
    canvas.drawArc(arcRect, math.pi, math.pi, true, face);
  }

  void _paintArcs(Canvas canvas, Rect arcRect) {
    canvas.drawArc(
      arcRect,
      _startAngle,
      _sweepAngle,
      false,
      Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.40 : 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawArc(
      arcRect.deflate(3),
      _startAngle,
      _sweepAngle,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.12 : 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final zoneStart = _angleFor(-0.10);
    final zoneSweep = _angleFor(0.10) - zoneStart;
    canvas.drawArc(
      arcRect.deflate(8),
      zoneStart,
      zoneSweep,
      false,
      Paint()
        ..color = centre
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5,
    );
  }

  void _paintTicks(Canvas canvas, Offset pivot, double radius) {
    for (var index = 0; index <= 20; index++) {
      final fraction = index / 20;
      final value = fraction * 2 - 1;
      final angle = _angleFor(value);
      final major = index % 5 == 0;
      final centreTick = index == 10;
      final outer = _polar(pivot, radius - 7, angle);
      final inner = _polar(pivot, radius - (major ? 27 : 18), angle);
      canvas.drawLine(
        outer,
        inner,
        Paint()
          ..color = centreTick ? centre : (major ? ink : grid)
          ..strokeCap = StrokeCap.square
          ..strokeWidth = centreTick ? 3 : (major ? 2 : 1),
      );
    }

    _drawText(
      canvas,
      '-50',
      _polar(pivot, radius - 44, _angleFor(-1)),
      11,
      mutedInk,
      TextAlign.center,
    );
    _drawText(
      canvas,
      '0',
      _polar(pivot, radius - 48, _angleFor(0)),
      12,
      centre,
      TextAlign.center,
      weight: FontWeight.w800,
    );
    _drawText(
      canvas,
      '+50',
      _polar(pivot, radius - 44, _angleFor(1)),
      11,
      mutedInk,
      TextAlign.center,
    );
  }

  void _paintNeedle(Canvas canvas, Offset pivot, double radius) {
    final angle = _angleFor(normalized);
    final tip = _polar(pivot, radius - 31, angle);
    final perpendicular = Offset(-math.sin(angle), math.cos(angle));
    final baseLeft = pivot + perpendicular * 3.3;
    final baseRight = pivot - perpendicular * 3.3;
    final needle = Path()
      ..moveTo(baseLeft.dx, baseLeft.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(baseRight.dx, baseRight.dy)
      ..close();
    final shadow = needle.shift(const Offset(2.2, 3.2));
    canvas.drawPath(
      shadow,
      Paint()..color = Colors.black.withValues(alpha: isDark ? 0.58 : 0.30),
    );
    canvas.drawPath(
      needle,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: hasReading ? 0.80 : 0.30),
            (hasReading ? needleColor : mutedInk).withValues(
              alpha: hasReading ? 1 : 0.45,
            ),
            Colors.black.withValues(alpha: 0.32),
          ],
        ).createShader(needle.getBounds()),
    );
  }

  void _paintPivot(Canvas canvas, Offset pivot, Size size) {
    canvas.drawCircle(
      pivot + const Offset(2, 3),
      15,
      Paint()..color = Colors.black.withValues(alpha: isDark ? 0.55 : 0.27),
    );
    canvas.drawCircle(
      pivot,
      14,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.5),
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.62 : 0.98),
            const Color(0xFFB7A18D),
            const Color(0xFF554438),
          ],
        ).createShader(Rect.fromCircle(center: pivot, radius: 14)),
    );
    canvas.drawCircle(
      pivot,
      7,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [
            Colors.white.withValues(alpha: 0.85),
            hasReading ? needleColor : mutedInk,
            Colors.black.withValues(alpha: 0.35),
          ],
        ).createShader(Rect.fromCircle(center: pivot, radius: 7)),
    );
  }

  double _angleFor(double value) =>
      _startAngle + ((value + 1) / 2) * _sweepAngle;

  Offset _polar(Offset origin, double radius, double angle) => Offset(
    origin.dx + math.cos(angle) * radius,
    origin.dy + math.sin(angle) * radius,
  );

  void _drawText(
    Canvas canvas,
    String text,
    Offset centrePoint,
    double fontSize,
    Color color,
    TextAlign align, {
    FontWeight weight = FontWeight.w600,
    double maxWidth = 64,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          letterSpacing: 0.2,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    painter.paint(
      canvas,
      Offset(
        centrePoint.dx - painter.width / 2,
        centrePoint.dy - painter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_AnalogDialPainter oldDelegate) =>
      oldDelegate.normalized != normalized ||
      oldDelegate.hasReading != hasReading ||
      oldDelegate.needleColor != needleColor ||
      oldDelegate.ink != ink ||
      oldDelegate.mutedInk != mutedInk ||
      oldDelegate.grid != grid ||
      oldDelegate.centre != centre ||
      oldDelegate.flatLabel != flatLabel ||
      oldDelegate.inTuneLabel != inTuneLabel ||
      oldDelegate.sharpLabel != sharpLabel ||
      oldDelegate.isDark != isDark;
}
