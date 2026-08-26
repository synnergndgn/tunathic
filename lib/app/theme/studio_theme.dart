import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_colors.dart';
import 'package:tunathic/app/theme/app_elevation.dart';
import 'package:tunathic/app/theme/app_radii.dart';

/// What a meter is currently reporting.
///
/// Kept free of any feature type so the theme layer stays underneath the
/// features that use it; the tuner maps its own accuracy and direction onto
/// this on the way in.
enum StudioSignal { idle, inTune, flat, sharp }

/// The surfaces and signal colours that make Tunathic read as one instrument.
///
/// Everything a screen needs to paint a device surface lives here, so screens
/// never hardcode a colour and light/dark stay defined side by side.
@immutable
final class StudioTheme extends ThemeExtension<StudioTheme> {
  const StudioTheme({
    required this.backdropTop,
    required this.backdropBottom,
    required this.panel,
    required this.panelRaised,
    required this.panelBorder,
    required this.panelBorderStrong,
    required this.display,
    required this.gridLine,
    required this.inTune,
    required this.flat,
    required this.sharp,
    required this.idle,
    required this.glowOpacity,
  });

  factory StudioTheme.of(BuildContext context) =>
      Theme.of(context).extension<StudioTheme>() ??
      StudioTheme.forBrightness(Theme.of(context).brightness);

  factory StudioTheme.forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? _dark : _light;

  static const _dark = StudioTheme(
    backdropTop: AppColors.stageTop,
    backdropBottom: AppColors.stageBottom,
    panel: AppColors.rackPanelDark,
    panelRaised: AppColors.rackPanelRaisedDark,
    panelBorder: AppColors.rackEdgeDark,
    panelBorderStrong: AppColors.rackEdgeStrongDark,
    display: AppColors.displayDark,
    gridLine: AppColors.rackEdgeDark,
    inTune: AppColors.signalInTune,
    flat: AppColors.signalFlat,
    sharp: AppColors.signalSharp,
    idle: Color(0xFF6A7C8C),
    glowOpacity: 0.12,
  );

  static const _light = StudioTheme(
    backdropTop: AppColors.stageTopLight,
    backdropBottom: AppColors.stageBottomLight,
    panel: AppColors.rackPanelLight,
    panelRaised: AppColors.rackPanelRaisedLight,
    panelBorder: AppColors.rackEdgeLight,
    panelBorderStrong: AppColors.rackEdgeStrongLight,
    display: AppColors.displayLight,
    gridLine: AppColors.rackEdgeLight,
    inTune: AppColors.signalInTuneLight,
    flat: AppColors.signalFlatLight,
    sharp: AppColors.signalSharpLight,
    idle: Color(0xFF64727F),
    glowOpacity: 0.08,
  );

  /// The backdrop of every studio screen.
  final Color backdropTop;
  final Color backdropBottom;

  /// A rack unit: the default surface for grouped controls.
  final Color panel;

  /// A rack unit that is selected, active, or carrying the primary action.
  final Color panelRaised;

  final Color panelBorder;
  final Color panelBorderStrong;

  /// The recessed readout a tuner or tempo value is printed on.
  final Color display;

  /// Faint ruling used by meters, ticks, and the backdrop signal lines.
  final Color gridLine;

  final Color inTune;
  final Color flat;
  final Color sharp;

  /// Nothing is being measured yet.
  final Color idle;

  /// How strongly a signal colour is allowed to bloom. Deliberately subtle so
  /// the readout feels illuminated without turning neon.
  final double glowOpacity;

  /// The colour for a reading, from how far off it is and which way.
  ///
  /// Green only ever means in tune. Cool means under pitch, warm means over,
  /// and neither is ever the sole carrier of the message: the meter, the arrow
  /// and the label say the same thing.
  Color signalColor(StudioSignal signal) => switch (signal) {
    StudioSignal.idle => idle,
    StudioSignal.inTune => inTune,
    StudioSignal.flat => flat,
    StudioSignal.sharp => sharp,
  };

  @override
  StudioTheme copyWith({
    Color? backdropTop,
    Color? backdropBottom,
    Color? panel,
    Color? panelRaised,
    Color? panelBorder,
    Color? panelBorderStrong,
    Color? display,
    Color? gridLine,
    Color? inTune,
    Color? flat,
    Color? sharp,
    Color? idle,
    double? glowOpacity,
  }) {
    return StudioTheme(
      backdropTop: backdropTop ?? this.backdropTop,
      backdropBottom: backdropBottom ?? this.backdropBottom,
      panel: panel ?? this.panel,
      panelRaised: panelRaised ?? this.panelRaised,
      panelBorder: panelBorder ?? this.panelBorder,
      panelBorderStrong: panelBorderStrong ?? this.panelBorderStrong,
      display: display ?? this.display,
      gridLine: gridLine ?? this.gridLine,
      inTune: inTune ?? this.inTune,
      flat: flat ?? this.flat,
      sharp: sharp ?? this.sharp,
      idle: idle ?? this.idle,
      glowOpacity: glowOpacity ?? this.glowOpacity,
    );
  }

  @override
  StudioTheme lerp(ThemeExtension<StudioTheme>? other, double t) {
    if (other is! StudioTheme) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return StudioTheme(
      backdropTop: mix(backdropTop, other.backdropTop),
      backdropBottom: mix(backdropBottom, other.backdropBottom),
      panel: mix(panel, other.panel),
      panelRaised: mix(panelRaised, other.panelRaised),
      panelBorder: mix(panelBorder, other.panelBorder),
      panelBorderStrong: mix(panelBorderStrong, other.panelBorderStrong),
      display: mix(display, other.display),
      gridLine: mix(gridLine, other.gridLine),
      inTune: mix(inTune, other.inTune),
      flat: mix(flat, other.flat),
      sharp: mix(sharp, other.sharp),
      idle: mix(idle, other.idle),
      glowOpacity: glowOpacity + (other.glowOpacity - glowOpacity) * t,
    );
  }
}

/// Ready-made decorations for the studio surfaces.
///
/// These exist so a screen asks for "a rack panel" instead of assembling a
/// colour, a border and a radius by hand every time.
abstract final class TunathicSurfaces {
  /// The full-bleed stage behind a screen.
  static BoxDecoration studioBackground(BuildContext context) {
    final studio = StudioTheme.of(context);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [studio.backdropTop, studio.backdropBottom],
      ),
    );
  }

  /// A display surface, sunk into the panel it sits on.
  ///
  /// The inset shading CSS gets from `inset` shadows has no [BoxDecoration]
  /// equivalent, so the darkening is blended into the surface colour and
  /// painted as a short gradient off the top edge instead.
  static LinearGradient _well(Brightness brightness, Color base) {
    final overlay = StudioElevation.wellOverlay(brightness);
    return LinearGradient(
      begin: overlay.begin,
      end: overlay.end,
      stops: overlay.stops,
      colors: [
        for (final color in overlay.colors) Color.alphaBlend(color, base),
      ],
    );
  }

  /// The recessed readout the tuner and tempo values are printed on.
  static BoxDecoration tunerDisplay(BuildContext context, {Color? signal}) {
    final studio = StudioTheme.of(context);
    final brightness = Theme.of(context).brightness;
    return BoxDecoration(
      gradient: _well(brightness, studio.display),
      borderRadius: AppRadii.deviceBorder,
      border: Border.all(
        color: signal == null
            ? studio.panelBorderStrong
            : signal.withValues(alpha: 0.55),
        width: signal == null ? 1 : 1.5,
      ),
    );
  }

  /// The enamel face of a rack unit. A short light-to-shadow transition sells
  /// the bevel without the heavy gradients the product direction avoids.
  static BoxDecoration rackFace(
    BuildContext context, {
    bool active = false,
    Color? accent,
  }) {
    final studio = StudioTheme.of(context);
    final face = active ? studio.panelRaised : studio.panel;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0, 0.48, 1],
        colors: [
          Color.alphaBlend(
            Colors.white.withValues(alpha: isDark ? 0.07 : 0.72),
            face,
          ),
          face,
          Color.alphaBlend(
            Colors.black.withValues(alpha: isDark ? 0.09 : 0.035),
            face,
          ),
        ],
      ),
      borderRadius: AppRadii.largeBorder,
      border: Border.all(
        color:
            accent ?? (active ? studio.panelBorderStrong : studio.panelBorder),
        width: accent != null ? 1.5 : 1,
      ),
    );
  }

  /// One rack unit. [active] lifts it for the row currently in use.
  static BoxDecoration rackPanel(
    BuildContext context, {
    bool active = false,
    Color? accent,
  }) {
    final brightness = Theme.of(context).brightness;
    final face = rackFace(context, active: active, accent: accent);
    return BoxDecoration(
      gradient: face.gradient,
      borderRadius: face.borderRadius,
      border: face.border,
      boxShadow: active
          ? StudioElevation.raised(brightness)
          : StudioElevation.panel(brightness),
    );
  }

  /// The horizontal strip tuning presets and other quick picks sit in.
  static BoxDecoration presetStrip(BuildContext context) {
    final studio = StudioTheme.of(context);
    final brightness = Theme.of(context).brightness;
    return BoxDecoration(
      gradient: _well(brightness, studio.display),
      borderRadius: AppRadii.largeBorder,
      border: Border.all(color: studio.panelBorder),
    );
  }

  /// The dock that carries a screen's primary controls.
  static BoxDecoration controlDock(BuildContext context) {
    final studio = StudioTheme.of(context);
    final brightness = Theme.of(context).brightness;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [studio.panelRaised, studio.panel],
      ),
      borderRadius: AppRadii.deviceBorder,
      border: Border.all(color: studio.panelBorderStrong),
      boxShadow: StudioElevation.raised(brightness),
    );
  }
}

/// The thin HUD brackets that mark a surface as instrumented.
///
/// Drawn only where something is actively reporting — an accented panel, a
/// live display — so they stay a signal rather than a texture.
final class StudioCornerBrackets extends StatelessWidget {
  const StudioCornerBrackets({
    required this.color,
    this.armLength = 10,
    this.thickness = 1.5,
    this.inset = 0,
    super.key,
  });

  final Color color;
  final double armLength;
  final double thickness;

  /// How far inside the surface edge the brackets sit. A display draws them
  /// clear of its own border; a panel draws them right on it.
  final double inset;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _CornerBracketPainter(
          color: color,
          armLength: armLength,
          thickness: thickness,
          inset: inset,
        ),
        isComplex: false,
        willChange: false,
      ),
    );
  }
}

final class _CornerBracketPainter extends CustomPainter {
  const _CornerBracketPainter({
    required this.color,
    required this.armLength,
    required this.thickness,
    required this.inset,
  });

  final Color color;
  final double armLength;
  final double thickness;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final left = inset + thickness / 2;
    final top = inset + thickness / 2;
    final right = size.width - inset - thickness / 2;
    final bottom = size.height - inset - thickness / 2;

    // An arm never grows past half the side it is on, so the brackets do not
    // meet in the middle on a small chip.
    final arm = math.min(
      armLength,
      math.min(size.width, size.height) / 2 - inset,
    );
    if (arm <= 0) return;

    void bracket(Offset corner, double dx, double dy) {
      canvas
        ..drawLine(corner, corner.translate(arm * dx, 0), paint)
        ..drawLine(corner, corner.translate(0, arm * dy), paint);
    }

    bracket(Offset(left, top), 1, 1);
    bracket(Offset(right, top), -1, 1);
    bracket(Offset(left, bottom), 1, -1);
    bracket(Offset(right, bottom), -1, -1);
  }

  @override
  bool shouldRepaint(_CornerBracketPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.armLength != armLength ||
      oldDelegate.thickness != thickness ||
      oldDelegate.inset != inset;
}
