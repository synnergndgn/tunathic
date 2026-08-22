import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_elevation.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/studio_theme.dart';

/// A raised enamel faceplate with a consistent top-left light source.
///
/// The surface is deliberately built from several layers: ambient and contact
/// shadows outside, a short enamel gradient, a metal lip, and painted inner
/// highlights/shadows. That combination is what makes it read as an object
/// instead of a Material card with elevation.
final class SkeuoSurface extends StatelessWidget {
  const SkeuoSurface({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = AppRadii.large,
    this.prominent = false,
    this.accent,
    this.surfaceColor,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Radius radius;
  final bool prominent;
  final Color? accent;
  final Color? surfaceColor;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studio = StudioTheme.of(context);
    final base =
        surfaceColor ?? (prominent ? studio.panelRaised : studio.panel);
    final borderRadius = BorderRadius.all(radius);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: prominent
            ? StudioElevation.instrumentRaised(theme.brightness)
            : StudioElevation.instrumentPanel(theme.brightness),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0, 0.16, 0.58, 1],
              colors: [
                Color.alphaBlend(
                  Colors.white.withValues(alpha: isDark ? 0.10 : 0.92),
                  base,
                ),
                Color.alphaBlend(
                  Colors.white.withValues(alpha: isDark ? 0.035 : 0.28),
                  base,
                ),
                base,
                Color.alphaBlend(
                  Colors.black.withValues(alpha: isDark ? 0.16 : 0.09),
                  base,
                ),
              ],
            ),
            borderRadius: borderRadius,
            border: Border.all(
              color: accent ?? studio.panelBorderStrong,
              width: accent == null ? 1.2 : 1.6,
            ),
          ),
          child: CustomPaint(
            painter: _SkeuoTexturePainter(isDark: isDark),
            foregroundPainter: _SkeuoEdgePainter(
              radius: radius.x,
              inset: false,
              isDark: isDark,
              accent: accent,
              screws: prominent,
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Drop-in physical replacement for simple Material cards.
///
/// Keeping this wrapper small lets content-heavy feature screens share the
/// same enamel, bevel and contact-shadow construction as the tuner faceplate.
final class SkeuoCard extends StatelessWidget {
  const SkeuoCard({
    required this.child,
    this.margin = EdgeInsets.zero,
    this.color,
    this.clipBehavior = Clip.antiAlias,
    this.shape,
    this.prominent = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final Clip clipBehavior;
  final ShapeBorder? shape;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final radius = shape == null ? AppRadii.large : AppRadii.small;
    return Padding(
      padding: margin,
      child: SkeuoSurface(
        radius: radius,
        prominent: prominent,
        surfaceColor: color,
        clipBehavior: clipBehavior,
        child: child,
      ),
    );
  }
}

final class _SkeuoTexturePainter extends CustomPainter {
  const _SkeuoTexturePainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final count = (size.width * size.height / 4200).round().clamp(8, 90);
    final points = <Offset>[];
    var seed = 0x4519;
    for (var index = 0; index < count; index++) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final x = seed / 0x7fffffff * size.width;
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final y = seed / 0x7fffffff * size.height;
      points.add(Offset(x, y));
    }
    canvas.drawPoints(
      PointMode.points,
      points,
      Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.04 : 0.018)
        ..strokeWidth = 0.65,
    );
  }

  @override
  bool shouldRepaint(_SkeuoTexturePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// A control well cut into a faceplate.
///
/// Flutter has no inset BoxShadow. The painter therefore draws the dark
/// top-left cavity edge and the reflected bottom-right lip inside the clip.
final class SkeuoInsetPanel extends StatelessWidget {
  const SkeuoInsetPanel({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = AppRadii.medium,
    this.accent,
    this.surfaceColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Radius radius;
  final Color? accent;
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studio = StudioTheme.of(context);
    final base = surfaceColor ?? studio.display;
    final borderRadius = BorderRadius.all(radius);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Color.alphaBlend(
          Colors.black.withValues(alpha: isDark ? 0.30 : 0.12),
          base,
        ),
        border: Border.all(
          color: accent?.withValues(alpha: 0.72) ?? studio.panelBorderStrong,
          width: accent == null ? 1.4 : 1.7,
        ),
        boxShadow: StudioElevation.instrumentWell(theme.brightness),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0, 0.22, 0.72, 1],
              colors: [
                Color.alphaBlend(
                  Colors.black.withValues(alpha: isDark ? 0.34 : 0.18),
                  base,
                ),
                Color.alphaBlend(
                  Colors.black.withValues(alpha: isDark ? 0.16 : 0.07),
                  base,
                ),
                base,
                Color.alphaBlend(
                  Colors.white.withValues(alpha: isDark ? 0.04 : 0.20),
                  base,
                ),
              ],
            ),
          ),
          child: CustomPaint(
            foregroundPainter: _SkeuoEdgePainter(
              radius: radius.x,
              inset: true,
              isDark: isDark,
              accent: accent,
              screws: false,
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// A recessed LCD/glass readout with fine scan lines and a glass highlight.
final class SkeuoDisplayPanel extends StatelessWidget {
  const SkeuoDisplayPanel({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.medium),
    this.radius = AppRadii.device,
    this.accent,
    this.surfaceColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Radius radius;
  final Color? accent;
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SkeuoInsetPanel(
      radius: radius,
      accent: accent,
      surfaceColor: surfaceColor,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _DisplayGlassPainter(isDark: isDark)),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// A small physical indicator lamp and engraved status label.
final class SkeuoStatusBadge extends StatelessWidget {
  const SkeuoStatusBadge({
    required this.label,
    required this.color,
    this.icon,
    this.active = true,
    super.key,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = active ? color : theme.colorScheme.onSurfaceVariant;
    return SkeuoInsetPanel(
      radius: AppRadii.medium,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.4),
                colors: [
                  Colors.white.withValues(alpha: active ? 0.95 : 0.45),
                  foreground,
                  Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.38),
                    foreground,
                  ),
                ],
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: foreground.withValues(alpha: 0.28),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(icon, size: 14, color: foreground),
          ],
          const SizedBox(width: AppSpacing.xs + 2),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _SkeuoEdgePainter extends CustomPainter {
  const _SkeuoEdgePainter({
    required this.radius,
    required this.inset,
    required this.isDark,
    required this.accent,
    required this.screws,
  });

  final double radius;
  final bool inset;
  final bool isDark;
  final Color? accent;
  final bool screws;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final inner = outer.deflate(2.2);

    final highlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = inset ? 1.6 : 1.25
      ..color = Colors.white.withValues(
        alpha: isDark ? (inset ? 0.08 : 0.16) : (inset ? 0.56 : 0.92),
      );
    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = inset ? 2.4 : 1.8
      ..color = Colors.black.withValues(
        alpha: isDark ? (inset ? 0.38 : 0.34) : (inset ? 0.22 : 0.14),
      );

    final topLeft = Path()
      ..moveTo(inner.left + radius, inner.top)
      ..lineTo(inner.right - radius, inner.top)
      ..arcToPoint(
        Offset(inner.right, inner.top + radius),
        radius: Radius.circular(radius),
      );
    final bottomRight = Path()
      ..moveTo(inner.right, inner.top + radius)
      ..lineTo(inner.right, inner.bottom - radius)
      ..arcToPoint(
        Offset(inner.right - radius, inner.bottom),
        radius: Radius.circular(radius),
      )
      ..lineTo(inner.left + radius, inner.bottom)
      ..arcToPoint(
        Offset(inner.left, inner.bottom - radius),
        radius: Radius.circular(radius),
      );

    canvas.drawPath(topLeft, inset ? shadow : highlight);
    canvas.drawPath(bottomRight, inset ? highlight : shadow);

    if (accent != null) {
      final accentPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = accent!.withValues(alpha: 0.38);
      canvas.drawRRect(outer.deflate(4), accentPaint);
    }

    if (screws && size.width >= 90 && size.height >= 56) {
      for (final centre in [
        const Offset(11, 11),
        Offset(size.width - 11, 11),
        Offset(11, size.height - 11),
        Offset(size.width - 11, size.height - 11),
      ]) {
        canvas.drawCircle(
          centre + const Offset(1, 1.5),
          4.3,
          Paint()..color = Colors.black.withValues(alpha: 0.20),
        );
        canvas.drawCircle(
          centre,
          4.1,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.4, -0.45),
              colors: [
                Colors.white.withValues(alpha: isDark ? 0.48 : 0.94),
                isDark ? const Color(0xFF806B5B) : const Color(0xFFB8A38F),
                isDark ? const Color(0xFF2D251F) : const Color(0xFF6B5544),
              ],
            ).createShader(Rect.fromCircle(center: centre, radius: 4.1)),
        );
        canvas.drawLine(
          centre.translate(-2.2, 0),
          centre.translate(2.2, 0),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.44)
            ..strokeWidth = 0.9,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SkeuoEdgePainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.inset != inset ||
      oldDelegate.isDark != isDark ||
      oldDelegate.accent != accent ||
      oldDelegate.screws != screws;
}

final class _DisplayGlassPainter extends CustomPainter {
  const _DisplayGlassPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final scan = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.075 : 0.035)
      ..strokeWidth = 0.7;
    for (var y = 5.0; y < size.height; y += 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scan);
    }

    final glareRect = Rect.fromLTWH(
      4,
      3,
      math.max(0, size.width - 8),
      math.min(34, size.height * 0.24),
    );
    final glare = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.11 : 0.34),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(glareRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(glareRect, const Radius.circular(12)),
      glare,
    );
  }

  @override
  bool shouldRepaint(_DisplayGlassPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
