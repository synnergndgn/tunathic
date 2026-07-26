import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tunathic/core/music_theory/fretboard.dart';

enum FretboardDisplayMode { notes, degrees }

final class InteractiveFretboardView extends StatelessWidget {
  const InteractiveFretboardView({
    required this.positions,
    required this.maximumFret,
    required this.displayMode,
    required this.semanticLabel,
    required this.onPositionSelected,
    super.key,
  });

  static const cellWidth = 52.0;
  static const stringLabelWidth = 44.0;
  static const height = 290.0;

  final List<FretPosition> positions;
  final int maximumFret;
  final FretboardDisplayMode displayMode;
  final String semanticLabel;
  final ValueChanged<FretPosition> onPositionSelected;

  @override
  Widget build(BuildContext context) {
    final width = stringLabelWidth + cellWidth * (maximumFret + 1);
    final colors = Theme.of(context).colorScheme;
    return Scrollbar(
      child: SingleChildScrollView(
        key: const Key('fretboardHorizontalScroll'),
        scrollDirection: Axis.horizontal,
        child: Semantics(
          label: semanticLabel,
          child: ExcludeSemantics(
            child: GestureDetector(
              key: const Key('fretboardGestureSurface'),
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final position = _FretboardGeometry.nearestMember(
                  details.localPosition,
                  positions,
                );
                if (position != null) onPositionSelected(position);
              },
              child: CustomPaint(
                key: const Key('interactiveFretboardCanvas'),
                size: Size(width, height),
                painter: _FretboardPainter(
                  positions: positions,
                  maximumFret: maximumFret,
                  displayMode: displayMode,
                  colors: colors,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class _FretboardGeometry {
  static const headerHeight = 34.0;
  static const firstStringY = 58.0;
  static const stringSpacing = 36.0;
  static const noteRadius = 16.0;

  static double get nutX =>
      InteractiveFretboardView.stringLabelWidth +
      InteractiveFretboardView.cellWidth;

  static Offset center(FretPosition position) {
    final x = position.fret == 0
        ? InteractiveFretboardView.stringLabelWidth +
              InteractiveFretboardView.cellWidth / 2
        : nutX + (position.fret - 0.5) * InteractiveFretboardView.cellWidth;
    // Standard player-view orientation: high E at top, low E at bottom.
    final y = firstStringY + (5 - position.stringIndex) * stringSpacing;
    return Offset(x, y);
  }

  static FretPosition? nearestMember(
    Offset point,
    List<FretPosition> positions,
  ) {
    FretPosition? closest;
    var closestDistance = double.infinity;
    for (final position in positions) {
      if (!position.isMember) continue;
      final distance = (center(position) - point).distanceSquared;
      if (distance < closestDistance) {
        closest = position;
        closestDistance = distance;
      }
    }
    return closestDistance <= math.pow(noteRadius + 7, 2) ? closest : null;
  }
}

final class _FretboardPainter extends CustomPainter {
  const _FretboardPainter({
    required this.positions,
    required this.maximumFret,
    required this.displayMode,
    required this.colors,
  });

  static const _singleMarkers = {3, 5, 7, 9, 15, 17, 19, 21};
  static const _doubleMarkers = {12, 24};

  final List<FretPosition> positions;
  final int maximumFret;
  final FretboardDisplayMode displayMode;
  final ColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final neckTop = _FretboardGeometry.firstStringY;
    final neckBottom = neckTop + _FretboardGeometry.stringSpacing * 5;
    final neckEnd =
        _FretboardGeometry.nutX +
        maximumFret * InteractiveFretboardView.cellWidth;

    canvas.drawRect(
      Rect.fromLTRB(_FretboardGeometry.nutX, neckTop, neckEnd, neckBottom),
      Paint()..color = colors.surfaceContainerHighest,
    );

    _paintMarkers(canvas, neckTop, neckBottom);
    _paintFrets(canvas, neckTop, neckBottom);
    _paintStrings(canvas);
    _paintPositions(canvas);
  }

  void _paintFrets(Canvas canvas, double top, double bottom) {
    final fretPaint = Paint()
      ..color = colors.outlineVariant
      ..strokeWidth = 1;
    final nutPaint = Paint()
      ..color = colors.onSurface
      ..strokeWidth = 4;
    canvas.drawLine(
      Offset(_FretboardGeometry.nutX, top - 2),
      Offset(_FretboardGeometry.nutX, bottom + 2),
      nutPaint,
    );
    for (var fret = 1; fret <= maximumFret; fret++) {
      final x =
          _FretboardGeometry.nutX + fret * InteractiveFretboardView.cellWidth;
      canvas.drawLine(Offset(x, top), Offset(x, bottom), fretPaint);
      _paintText(
        canvas,
        '$fret',
        Offset(
          x - InteractiveFretboardView.cellWidth / 2,
          _FretboardGeometry.headerHeight / 2,
        ),
        colors.onSurfaceVariant,
        fontSize: 11,
      );
    }
    _paintText(
      canvas,
      '0',
      const Offset(
        InteractiveFretboardView.stringLabelWidth +
            InteractiveFretboardView.cellWidth / 2,
        _FretboardGeometry.headerHeight / 2,
      ),
      colors.onSurfaceVariant,
      fontSize: 11,
    );
  }

  void _paintStrings(Canvas canvas) {
    for (var index = 0; index < 6; index++) {
      final y =
          _FretboardGeometry.firstStringY +
          (5 - index) * _FretboardGeometry.stringSpacing;
      final weight = 1.0 + (5 - index) * 0.25;
      canvas.drawLine(
        Offset(InteractiveFretboardView.stringLabelWidth, y),
        Offset(
          _FretboardGeometry.nutX +
              maximumFret * InteractiveFretboardView.cellWidth,
          y,
        ),
        Paint()
          ..color = colors.onSurfaceVariant
          ..strokeWidth = weight,
      );
      final string = positions.firstWhere(
        (position) => position.stringIndex == index,
      );
      _paintText(
        canvas,
        string.stringLabel,
        Offset(20, y),
        colors.onSurface,
        fontSize: 11,
      );
    }
  }

  void _paintMarkers(Canvas canvas, double top, double bottom) {
    final markerPaint = Paint()
      ..color = colors.onSurfaceVariant.withValues(alpha: 0.22);
    final middle = (top + bottom) / 2;
    for (var fret = 1; fret <= maximumFret; fret++) {
      if (!_singleMarkers.contains(fret) && !_doubleMarkers.contains(fret)) {
        continue;
      }
      final x =
          _FretboardGeometry.nutX +
          (fret - 0.5) * InteractiveFretboardView.cellWidth;
      if (_doubleMarkers.contains(fret)) {
        canvas.drawCircle(Offset(x, middle - 38), 4, markerPaint);
        canvas.drawCircle(Offset(x, middle + 38), 4, markerPaint);
      } else {
        canvas.drawCircle(Offset(x, middle), 4, markerPaint);
      }
    }
  }

  void _paintPositions(Canvas canvas) {
    for (final position in positions) {
      final relation = position.relation;
      if (relation == null) continue;
      final center = _FretboardGeometry.center(position);
      final fill = Paint()
        ..color = position.isRoot ? colors.primary : colors.secondaryContainer;
      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = position.isRoot ? 3 : 1.5
        ..color = position.isRoot ? colors.onSurface : colors.outline;
      if (position.isRoot) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromCircle(
            center: center,
            radius: _FretboardGeometry.noteRadius,
          ),
          const Radius.circular(5),
        );
        canvas.drawRRect(rect, fill);
        canvas.drawRRect(rect.inflate(2), outline);
      } else {
        canvas.drawCircle(center, _FretboardGeometry.noteRadius, fill);
        canvas.drawCircle(center, _FretboardGeometry.noteRadius, outline);
      }
      _paintText(
        canvas,
        displayMode == FretboardDisplayMode.notes
            ? relation.pitch.symbol
            : relation.symbol,
        center,
        position.isRoot ? colors.onPrimary : colors.onSecondaryContainer,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      );
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset center,
    Color color, {
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _FretboardPainter oldDelegate) =>
      oldDelegate.positions != positions ||
      oldDelegate.maximumFret != maximumFret ||
      oldDelegate.displayMode != displayMode ||
      oldDelegate.colors != colors;
}
