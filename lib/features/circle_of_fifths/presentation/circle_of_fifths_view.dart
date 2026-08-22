import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/circle_of_fifths/presentation/circle_of_fifths_localizations.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

final class CircleOfFifthsView extends StatelessWidget {
  const CircleOfFifthsView({
    required this.selectedKey,
    required this.onSelected,
    super.key,
  });

  final MusicalKey selectedKey;
  final ValueChanged<MusicalKey> onSelected;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    if (textScale >= 1.6) {
      return _AccessibleCircleOrder(
        selectedKey: selectedKey,
        onSelected: onSelected,
      );
    }

    final relative = selectedKey.relativeKey;
    final fifth = CircleOfFifths.clockwiseNeighbor(selectedKey);
    final fourth = CircleOfFifths.counterClockwiseNeighbor(selectedKey);
    final selectedPosition = CircleOfFifths.positionFor(selectedKey);
    final summary = localizations.circleSemantics(
      localizations.keyName(selectedKey),
      localizations.keyName(relative),
      localizations.keyName(fifth),
      localizations.keyName(fourth),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 520.0);
        final outerRadius = size * 0.41;
        final innerRadius = size * 0.27;
        final outerButtonSize = size < 400 ? 52.0 : 64.0;
        final innerButtonSize = size < 400 ? 48.0 : 56.0;

        return Center(
          child: Semantics(
            container: true,
            label: summary,
            child: SizedBox.square(
              key: const Key('circleVisualization'),
              dimension: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ExcludeSemantics(
                      child: CustomPaint(
                        painter: CircleOfFifthsPainter(
                          selectedIndex: selectedPosition.index,
                          colorScheme: Theme.of(context).colorScheme,
                        ),
                      ),
                    ),
                  ),
                  for (final position in CircleOfFifths.positions) ...[
                    _positionedKey(
                      context: context,
                      size: size,
                      radius: outerRadius,
                      buttonSize: outerButtonSize,
                      position: position,
                      key: position.major,
                      label: localizations.circlePositionMajorLabel(position),
                      fifth: fifth,
                      fourth: fourth,
                      relative: relative,
                      keyPrefix: 'circleMajor',
                    ),
                    _positionedKey(
                      context: context,
                      size: size,
                      radius: innerRadius,
                      buttonSize: innerButtonSize,
                      position: position,
                      key: position.relativeMinor,
                      label: localizations.circlePositionMinorLabel(position),
                      fifth: fifth,
                      fourth: fourth,
                      relative: relative,
                      keyPrefix: 'circleMinor',
                    ),
                  ],
                  Center(
                    child: ExcludeSemantics(
                      child: SizedBox(
                        width: size * 0.27,
                        child: Text(
                          localizations.keyName(selectedKey),
                          key: const Key('circleCenterKey'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _positionedKey({
    required BuildContext context,
    required double size,
    required double radius,
    required double buttonSize,
    required CirclePosition position,
    required MusicalKey key,
    required String label,
    required MusicalKey fifth,
    required MusicalKey fourth,
    required MusicalKey relative,
    required String keyPrefix,
  }) {
    final angle = -math.pi / 2 + position.index * math.pi / 6;
    final center = Offset(
      size / 2 + math.cos(angle) * radius,
      size / 2 + math.sin(angle) * radius,
    );
    return Positioned(
      left: center.dx - buttonSize / 2,
      top: center.dy - buttonSize / 2,
      width: buttonSize,
      height: buttonSize,
      child: _CircleKeyButton(
        key: Key('$keyPrefix-${position.index}'),
        musicalKey: key,
        label: label,
        selected: _sameIdentity(key, selectedKey),
        relative: _sameIdentity(key, relative),
        fifth: _sameIdentity(key, fifth),
        fourth: _sameIdentity(key, fourth),
        onTap: () => onSelected(_keyForTap(position, key.tonality)),
      ),
    );
  }

  MusicalKey _keyForTap(CirclePosition position, KeyTonality tonality) {
    final primary = tonality == KeyTonality.major
        ? position.major
        : position.relativeMinor;
    final alternate = tonality == KeyTonality.major
        ? position.alternateMajor
        : position.alternateRelativeMinor;
    if (alternate != null &&
        selectedKey.tonality == tonality &&
        selectedKey.tonic == primary.tonic) {
      return alternate;
    }
    if (alternate != null &&
        selectedKey.tonality == tonality &&
        selectedKey.tonic == alternate.tonic) {
      return primary;
    }
    return primary;
  }

  bool _sameIdentity(MusicalKey first, MusicalKey second) =>
      first.tonality == second.tonality &&
      first.tonic.pitchClass == second.tonic.pitchClass;
}

final class _CircleKeyButton extends StatelessWidget {
  const _CircleKeyButton({
    required this.musicalKey,
    required this.label,
    required this.selected,
    required this.relative,
    required this.fifth,
    required this.fourth,
    required this.onTap,
    super.key,
  });

  final MusicalKey musicalKey;
  final String label;
  final bool selected;
  final bool relative;
  final bool fifth;
  final bool fourth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final relationship = selected
        ? localizations.selectedKeyIndicator
        : relative
        ? localizations.relativeKeyIndicator
        : fifth
        ? localizations.fifthNeighborIndicator
        : fourth
        ? localizations.fourthNeighborIndicator
        : localizations.keyTonalityName(musicalKey.tonality);
    final icon = selected
        ? Icons.check
        : relative
        ? Icons.link
        : fifth
        ? Icons.arrow_forward
        : fourth
        ? Icons.arrow_back
        : null;
    final shape = musicalKey.tonality == KeyTonality.major
        ? RoundedRectangleBorder(
            borderRadius: AppRadii.mediumBorder,
            side: BorderSide(
              color: selected || relative || fifth || fourth
                  ? colors.primary
                  : colors.outline,
              width: selected
                  ? 3
                  : relative
                  ? 2
                  : 1,
            ),
          )
        : CircleBorder(
            side: BorderSide(
              color: selected || relative || fifth || fourth
                  ? colors.secondary
                  : colors.outlineVariant,
              width: selected
                  ? 3
                  : relative
                  ? 2
                  : 1,
            ),
          );

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: localizations.circleKeySemantics(label, relationship),
      onTap: onTap,
      child: Material(
        color: selected
            ? colors.primaryContainer
            : relative
            ? colors.secondaryContainer
            : colors.surfaceContainerHighest,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: ExcludeSemantics(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xSmall),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (icon != null)
                  PositionedDirectional(
                    top: 2,
                    end: 2,
                    child: Icon(icon, size: 12),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _AccessibleCircleOrder extends StatelessWidget {
  const _AccessibleCircleOrder({
    required this.selectedKey,
    required this.onSelected,
  });

  final MusicalKey selectedKey;
  final ValueChanged<MusicalKey> onSelected;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      key: const Key('circleAccessibleOrder'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            localizations.circleLargeTextOrder,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        for (final position in CircleOfFifths.positions)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: SkeuoCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.small),
                child: Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: [
                    _orderButton(
                      context,
                      position.major,
                      localizations.circlePositionMajorLabel(position),
                      position,
                    ),
                    _orderButton(
                      context,
                      position.relativeMinor,
                      localizations.circlePositionMinorLabel(position),
                      position,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _orderButton(
    BuildContext context,
    MusicalKey key,
    String tonicLabel,
    CirclePosition position,
  ) {
    final localizations = AppLocalizations.of(context);
    final selected =
        selectedKey.tonality == key.tonality &&
        selectedKey.tonic.pitchClass == key.tonic.pitchClass;
    return SkeuoButton(
      key: Key(
        '${key.tonality == KeyTonality.major ? 'circleMajor' : 'circleMinor'}'
        '-${position.index}',
      ),
      onPressed: () => onSelected(key),
      compact: true,
      selected: selected,
      icon: selected ? Icons.check : Icons.music_note_outlined,
      child: Text('$tonicLabel ${localizations.keyTonalityName(key.tonality)}'),
    );
  }
}

final class CircleOfFifthsPainter extends CustomPainter {
  const CircleOfFifthsPainter({
    required this.selectedIndex,
    required this.colorScheme,
  });

  final int selectedIndex;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide * 0.41;
    final innerRadius = size.shortestSide * 0.27;
    final middleRadius = (outerRadius + innerRadius) / 2;
    final ringWidth = outerRadius - innerRadius;

    final selectedPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.butt;
    final neighborPaint = Paint()
      ..color = colorScheme.secondary.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.butt;
    final start = -math.pi / 2 + selectedIndex * math.pi / 6 - math.pi / 12;
    final bounds = Rect.fromCircle(center: center, radius: middleRadius);
    canvas.drawArc(bounds, start, math.pi / 6, false, selectedPaint);
    canvas.drawArc(
      bounds,
      start - math.pi / 6,
      math.pi / 6,
      false,
      neighborPaint,
    );
    canvas.drawArc(
      bounds,
      start + math.pi / 6,
      math.pi / 6,
      false,
      neighborPaint,
    );

    final linePaint = Paint()
      ..color = colorScheme.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, outerRadius, linePaint);
    canvas.drawCircle(center, innerRadius, linePaint);
    for (var index = 0; index < 12; index++) {
      final angle = -math.pi / 2 + index * math.pi / 6 - math.pi / 12;
      canvas.drawLine(
        center +
            Offset(
              math.cos(angle) * (innerRadius - 20),
              math.sin(angle) * (innerRadius - 20),
            ),
        center +
            Offset(
              math.cos(angle) * (outerRadius + 20),
              math.sin(angle) * (outerRadius + 20),
            ),
        linePaint,
      );
    }

    canvas.drawCircle(
      center,
      innerRadius * 0.56,
      Paint()..color = colorScheme.surface,
    );
    canvas.drawCircle(center, innerRadius * 0.56, linePaint);
  }

  @override
  bool shouldRepaint(CircleOfFifthsPainter oldDelegate) =>
      selectedIndex != oldDelegate.selectedIndex ||
      colorScheme != oldDelegate.colorScheme;
}
