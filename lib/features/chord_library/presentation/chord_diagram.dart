import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tunathic/features/chord_library/domain/guitar_chord_shape.dart';
import 'package:tunathic/features/chord_library/presentation/chord_library_localizations.dart';
import 'package:tunathic/l10n/app_localizations.dart';

final class ChordDiagram extends StatelessWidget {
  const ChordDiagram({
    required this.shape,
    required this.chordSymbol,
    super.key,
  });

  final GuitarChordShape shape;
  final String chordSymbol;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final semantics = _semanticsDescription(localizations);
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      image: true,
      label: localizations.chordDiagramSemantics(chordSymbol, semantics),
      child: ExcludeSemantics(
        child: AspectRatio(
          aspectRatio: 0.82,
          child: CustomPaint(
            key: const Key('chordDiagramCanvas'),
            painter: _ChordDiagramPainter(
              shape: shape,
              foreground: colors.onSurface,
              marker: colors.primary,
              markerForeground: colors.onPrimary,
              secondary: colors.outline,
            ),
          ),
        ),
      ),
    );
  }

  String _semanticsDescription(AppLocalizations localizations) {
    final stringNames = localizations.guitarStringNames;
    final parts = <String>[];
    for (var index = 0; index < shape.strings.length; index++) {
      final string = shape.strings[index];
      final stringName = stringNames[index];
      parts.add(switch (string.kind) {
        GuitarStringKind.muted => localizations.guitarStringMutedDescription(
          stringName,
        ),
        GuitarStringKind.open => localizations.guitarStringOpenDescription(
          stringName,
        ),
        GuitarStringKind.fretted when string.finger != null =>
          localizations.guitarStringFingerDescription(
            stringName,
            string.fret,
            string.finger!,
          ),
        GuitarStringKind.fretted =>
          localizations.guitarStringFrettedDescription(stringName, string.fret),
      });
    }
    for (final barre in shape.barres) {
      parts.add(
        localizations.barreDescription(
          barre.fret,
          stringNames[barre.fromString],
          stringNames[barre.toStringIndex],
          barre.finger,
        ),
      );
    }
    return parts.join(' ');
  }
}

final class _ChordDiagramPainter extends CustomPainter {
  const _ChordDiagramPainter({
    required this.shape,
    required this.foreground,
    required this.marker,
    required this.markerForeground,
    required this.secondary,
  });

  final GuitarChordShape shape;
  final Color foreground;
  final Color marker;
  final Color markerForeground;
  final Color secondary;

  static const _fretCount = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.17;
    final right = size.width * 0.92;
    final top = size.height * 0.18;
    final bottom = size.height * 0.94;
    final stringGap = (right - left) / 5;
    final fretGap = (bottom - top) / _fretCount;

    final linePaint = Paint()
      ..color = foreground
      ..strokeCap = StrokeCap.square;
    final secondaryPaint = Paint()
      ..color = secondary
      ..strokeWidth = 1.2;

    for (var fret = 0; fret <= _fretCount; fret++) {
      final y = top + fret * fretGap;
      linePaint.strokeWidth = fret == 0 && shape.startingFret == 1 ? 5 : 1.4;
      canvas.drawLine(Offset(left, y), Offset(right, y), linePaint);
    }

    for (var stringIndex = 0; stringIndex < 6; stringIndex++) {
      final x = left + stringIndex * stringGap;
      secondaryPaint.strokeWidth = 2.1 - stringIndex * 0.18;
      canvas.drawLine(Offset(x, top), Offset(x, bottom), secondaryPaint);
    }

    if (shape.startingFret > 1) {
      _drawText(
        canvas,
        '${shape.startingFret}',
        Offset(left - size.width * 0.1, top + fretGap * 0.34),
        foreground,
        size.width * 0.055,
      );
    }

    for (final barre in shape.barres) {
      final y = top + (barre.fret - shape.startingFret + 0.5) * fretGap;
      final fromX = left + barre.fromString * stringGap;
      final toX = left + barre.toStringIndex * stringGap;
      final barrePaint = Paint()
        ..color = marker
        ..strokeWidth = math.max(16, stringGap * 0.56)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(fromX, y), Offset(toX, y), barrePaint);
      _drawCenteredText(
        canvas,
        '${barre.finger}',
        Offset((fromX + toX) / 2, y),
        markerForeground,
        size.width * 0.05,
      );
    }

    for (
      var stringIndex = 0;
      stringIndex < shape.strings.length;
      stringIndex++
    ) {
      final string = shape.strings[stringIndex];
      final x = left + stringIndex * stringGap;
      if (string.kind != GuitarStringKind.fretted) {
        _drawCenteredText(
          canvas,
          string.kind == GuitarStringKind.muted ? '×' : '○',
          Offset(x, top - size.height * 0.08),
          foreground,
          size.width * 0.075,
        );
        continue;
      }

      final y = top + (string.fret - shape.startingFret + 0.5) * fretGap;
      final dotPaint = Paint()..color = marker;
      canvas.drawCircle(
        Offset(x, y),
        math.min(stringGap, fretGap) * 0.27,
        dotPaint,
      );
      if (string.finger != null) {
        _drawCenteredText(
          canvas,
          '${string.finger}',
          Offset(x, y),
          markerForeground,
          size.width * 0.047,
        );
      }
    }
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center,
    Color color,
    double fontSize,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double fontSize,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_ChordDiagramPainter oldDelegate) =>
      shape.id != oldDelegate.shape.id ||
      foreground != oldDelegate.foreground ||
      marker != oldDelegate.marker ||
      markerForeground != oldDelegate.markerForeground ||
      secondary != oldDelegate.secondary;
}
