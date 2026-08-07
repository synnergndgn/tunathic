import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';

enum TheoryMarkerEmphasis { root, member, target }

/// One dot on a lesson diagram.
final class TheoryFretMarker {
  const TheoryFretMarker({
    required this.stringIndex,
    required this.fret,
    required this.label,
    required this.emphasis,
  });

  /// Low to high, matching the shared tuning model.
  final int stringIndex;
  final int fret;
  final String label;
  final TheoryMarkerEmphasis emphasis;
}

/// A compact, read-only fretboard window used by lesson diagrams.
///
/// It renders markers that callers derive from the shared theory engine, so
/// the widget never decides which notes belong to a chord, a scale, or an
/// interval shape. The whole diagram carries a single semantic label, because
/// a screen reader announcing forty dots is worse than one clear sentence.
final class TheoryFretboardView extends StatelessWidget {
  const TheoryFretboardView({
    required this.markers,
    required this.firstFret,
    required this.lastFret,
    required this.stringLabels,
    required this.semanticLabel,
    super.key,
  });

  static const cellWidth = 42.0;
  static const labelColumnWidth = 32.0;
  static const headerHeight = 20.0;
  static const stringSpacing = 26.0;
  static const markerRadius = 11.0;

  final List<TheoryFretMarker> markers;
  final int firstFret;
  final int lastFret;

  /// String names, low to high.
  final List<String> stringLabels;
  final String semanticLabel;

  int get _fretCount => lastFret - firstFret + 1;

  double get _width => labelColumnWidth + cellWidth * _fretCount;

  double get _height =>
      headerHeight + stringSpacing * stringLabels.length + AppSpacing.small;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: CustomPaint(
              size: Size(_width, _height),
              painter: _TheoryFretboardPainter(
                markers: markers,
                firstFret: firstFret,
                lastFret: lastFret,
                stringLabels: stringLabels,
                colors: colors,
                textDirection: Directionality.of(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _TheoryFretboardPainter extends CustomPainter {
  const _TheoryFretboardPainter({
    required this.markers,
    required this.firstFret,
    required this.lastFret,
    required this.stringLabels,
    required this.colors,
    required this.textDirection,
  });

  final List<TheoryFretMarker> markers;
  final int firstFret;
  final int lastFret;
  final List<String> stringLabels;
  final ColorScheme colors;
  final TextDirection textDirection;

  static const _inlayFrets = {3, 5, 7, 9, 15, 17, 19, 21};

  @override
  void paint(Canvas canvas, Size size) {
    final stringCount = stringLabels.length;
    final boardLeft = TheoryFretboardView.labelColumnWidth;
    final firstStringY =
        TheoryFretboardView.headerHeight +
        TheoryFretboardView.stringSpacing / 2;

    final gridPaint = Paint()
      ..color = colors.outlineVariant
      ..strokeWidth = 1;
    final nutPaint = Paint()
      ..color = colors.outline
      ..strokeWidth = 3;

    // Fret numbers and vertical fret wires.
    for (var fret = firstFret; fret <= lastFret; fret++) {
      final x =
          boardLeft + (fret - firstFret + 1) * TheoryFretboardView.cellWidth;
      canvas.drawLine(
        Offset(x, firstStringY),
        Offset(
          x,
          firstStringY + (stringCount - 1) * TheoryFretboardView.stringSpacing,
        ),
        fret == 0 ? nutPaint : gridPaint,
      );
      _paintText(
        canvas,
        '$fret',
        Offset(x - TheoryFretboardView.cellWidth / 2, 2),
        colors.onSurfaceVariant,
        11,
      );
      if (_inlayFrets.contains(fret) || fret == 12 || fret == 24) {
        _paintText(
          canvas,
          fret == 12 || fret == 24 ? '••' : '•',
          Offset(
            x - TheoryFretboardView.cellWidth / 2,
            firstStringY +
                (stringCount - 1) * TheoryFretboardView.stringSpacing +
                2,
          ),
          colors.outlineVariant,
          11,
        );
      }
    }

    // Strings, drawn high to low so the view matches the player's own.
    for (var index = 0; index < stringCount; index++) {
      final y = firstStringY + index * TheoryFretboardView.stringSpacing;
      canvas.drawLine(
        Offset(boardLeft, y),
        Offset(
          boardLeft +
              (lastFret - firstFret + 1) * TheoryFretboardView.cellWidth,
          y,
        ),
        gridPaint,
      );
      _paintText(
        canvas,
        stringLabels[stringCount - 1 - index],
        Offset(TheoryFretboardView.labelColumnWidth / 2, y - 8),
        colors.onSurfaceVariant,
        11,
      );
    }

    for (final marker in markers) {
      if (marker.fret < firstFret || marker.fret > lastFret) continue;
      final rowFromTop = stringCount - 1 - marker.stringIndex;
      final center = Offset(
        boardLeft +
            (marker.fret - firstFret + 0.5) * TheoryFretboardView.cellWidth,
        firstStringY + rowFromTop * TheoryFretboardView.stringSpacing,
      );
      final fill = switch (marker.emphasis) {
        TheoryMarkerEmphasis.root => colors.primary,
        TheoryMarkerEmphasis.target => colors.tertiary,
        TheoryMarkerEmphasis.member => colors.surfaceContainerHighest,
      };
      final foreground = switch (marker.emphasis) {
        TheoryMarkerEmphasis.root => colors.onPrimary,
        TheoryMarkerEmphasis.target => colors.onTertiary,
        TheoryMarkerEmphasis.member => colors.onSurface,
      };
      canvas.drawCircle(
        center,
        TheoryFretboardView.markerRadius,
        Paint()..color = fill,
      );
      canvas.drawCircle(
        center,
        TheoryFretboardView.markerRadius,
        Paint()
          ..color = colors.outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      _paintText(canvas, marker.label, center.translate(0, -7), foreground, 11);
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset center,
    Color color,
    double size,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: textDirection,
    )..layout();
    painter.paint(canvas, Offset(center.dx - painter.width / 2, center.dy));
  }

  @override
  bool shouldRepaint(_TheoryFretboardPainter oldDelegate) =>
      oldDelegate.markers != markers ||
      oldDelegate.firstFret != firstFret ||
      oldDelegate.lastFret != lastFret ||
      oldDelegate.colors != colors;
}
