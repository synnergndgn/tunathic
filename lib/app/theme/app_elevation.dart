import 'package:flutter/material.dart';

/// Material's own elevation, still used where a Material widget asks for a
/// number rather than a shadow.
abstract final class AppElevation {
  static const flat = 0.0;
  static const raised = 1.0;
}

/// The studio depth scale.
///
/// A rack unit is lit from above: a tight contact shadow, a wider ambient one,
/// and a hairline highlight along the top edge where the light catches the
/// bevel. Screens never assemble these by hand — [TunathicSurfaces] and the
/// studio widgets apply them.
///
/// CSS's inset shadows have no equivalent in [BoxDecoration], so the two
/// recessed steps ([wellOverlay], [pressedOverlay]) are expressed as gradients
/// painted inside the surface instead of as shadows on it.
abstract final class StudioElevation {
  /// The full physical faceplate stack. Light comes from the top-left, so the
  /// pale halo sits there while the contact and ambient shadows fall toward
  /// the bottom-right.
  static List<BoxShadow> instrumentPanel(Brightness brightness) =>
      brightness == Brightness.dark
      ? const [
          BoxShadow(
            color: Color(0x8A000000),
            blurRadius: 2,
            offset: Offset(2, 3),
          ),
          BoxShadow(
            color: Color(0x52000000),
            blurRadius: 14,
            offset: Offset(5, 8),
          ),
          BoxShadow(
            color: Color(0x18FFFFFF),
            blurRadius: 2,
            offset: Offset(-2, -2),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x3D5A3A24),
            blurRadius: 2,
            offset: Offset(2, 3),
          ),
          BoxShadow(
            color: Color(0x2B6B4A32),
            blurRadius: 16,
            offset: Offset(6, 9),
          ),
          BoxShadow(
            color: Color(0xE6FFFFFF),
            blurRadius: 3,
            offset: Offset(-3, -3),
          ),
        ];

  /// A control or primary module lifted further off the faceplate.
  static List<BoxShadow> instrumentRaised(Brightness brightness) =>
      brightness == Brightness.dark
      ? const [
          BoxShadow(
            color: Color(0xA6000000),
            blurRadius: 3,
            offset: Offset(2, 4),
          ),
          BoxShadow(
            color: Color(0x70000000),
            blurRadius: 22,
            offset: Offset(7, 12),
          ),
          BoxShadow(
            color: Color(0x24FFFFFF),
            blurRadius: 3,
            offset: Offset(-3, -3),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x525A3A24),
            blurRadius: 3,
            offset: Offset(2, 4),
          ),
          BoxShadow(
            color: Color(0x386B4A32),
            blurRadius: 24,
            offset: Offset(8, 13),
          ),
          BoxShadow(
            color: Color(0xFFFFFFFF),
            blurRadius: 4,
            offset: Offset(-4, -4),
          ),
        ];

  /// The lip around a cavity. The inset itself is painted by
  /// `SkeuoInsetPanel`; these small opposing shadows make the cut edge catch
  /// the same directional light as the raised surfaces.
  static List<BoxShadow> instrumentWell(Brightness brightness) =>
      brightness == Brightness.dark
      ? const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 4,
            offset: Offset(-1, -1),
          ),
          BoxShadow(
            color: Color(0x16FFFFFF),
            blurRadius: 2,
            offset: Offset(1, 2),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x526B4A32),
            blurRadius: 5,
            offset: Offset(-2, -2),
          ),
          BoxShadow(
            color: Color(0xCCFFFFFF),
            blurRadius: 2,
            offset: Offset(2, 3),
          ),
        ];

  /// The default rack unit.
  static List<BoxShadow> panel(Brightness brightness) =>
      brightness == Brightness.dark
      ? const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x246B4A32),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x206B4A32),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: Color(0xA6FFFFFF),
            blurRadius: 1,
            offset: Offset(0, -1),
          ),
        ];

  /// The row currently in use.
  static List<BoxShadow> raised(Brightness brightness) =>
      brightness == Brightness.dark
      ? const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x336B4A32),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: Color(0x2B6B4A32),
            blurRadius: 20,
            offset: Offset(0, 9),
          ),
          BoxShadow(
            color: Color(0xCCFFFFFF),
            blurRadius: 1,
            offset: Offset(0, -1),
          ),
        ];

  /// Something floating over the stage: a sheet, a menu, a dialog.
  static List<BoxShadow> float(Brightness brightness) =>
      brightness == Brightness.dark
      ? const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x406B4A32),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
          BoxShadow(
            color: Color(0x296B4A32),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ];

  /// The hairline the bevel catches along a panel's top edge.
  static Color bevelHighlight(Brightness brightness, {bool active = false}) =>
      brightness == Brightness.dark
      ? Color.fromRGBO(255, 255, 255, active ? 0.09 : 0.06)
      : Color.fromRGBO(255, 255, 255, active ? 1 : 0.9);

  /// A recessed readout. Painted inside the surface, darkest at the top edge,
  /// which is what sells the display as sunk into the panel.
  static LinearGradient wellOverlay(Brightness brightness) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: brightness == Brightness.dark
        ? const [Color(0x8C000000), Color(0x00000000)]
        : const [Color(0x306B4A32), Color(0x006B4A32)],
    stops: const [0, 0.35],
  );

  /// A control being held down.
  static LinearGradient pressedOverlay(Brightness brightness) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: brightness == Brightness.dark
        ? const [Color(0x8C000000), Color(0x00000000)]
        : const [Color(0x386B4A32), Color(0x006B4A32)],
    stops: const [0, 0.5],
  );
}
