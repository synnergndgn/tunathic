import 'package:flutter/material.dart';

/// The raw Tunathic palette.
///
/// Screens should not read these directly. They reach the studio surfaces and
/// signal colours through [ColorScheme] or the `StudioTheme` extension so that
/// light and dark stay in sync from one place.
abstract final class AppColors {
  // Brand anchors. The legacy names remain aliases while older feature code
  // moves to the semantic palette below.
  static const warmOrange = Color(0xFFC85818);
  static const amber = Color(0xFFE1842F);
  static const mutedCopper = Color(0xFF9A6547);
  static const burntOrange = Color(0xFFA84312);
  static const deepCharcoal = Color(0xFF302822);
  static const charcoalSurface = Color(0xFF4B3E35);
  static const electricBlue = warmOrange;
  static const softCyan = mutedCopper;
  static const offWhite = Color(0xFFFFFAF2);
  static const lightSurface = Color(0xFFF5EEE3);
  static const lightCard = Color(0xFFFFFDF8);
  static const lightOutline = Color(0xFF8A7461);

  // Night workshop: warm brown rather than a near-black or neon dark theme.
  static const stageTop = Color(0xFF4A3C32);
  static const stageBottom = Color(0xFF332923);
  static const rackPanelDark = Color(0xFF514238);
  static const rackPanelRaisedDark = Color(0xFF5D4B3F);
  static const displayDark = Color(0xFF2C2521);
  static const rackEdgeDark = Color(0xFF6E594B);
  static const rackEdgeStrongDark = Color(0xFF92755F);

  // Daylight workbench: ivory enamel, cream faceplates, and warm metal trim.
  static const stageTopLight = Color(0xFFFFFDF8);
  static const stageBottomLight = Color(0xFFF1E8DC);
  static const rackPanelLight = Color(0xFFF8F1E7);
  static const rackPanelRaisedLight = Color(0xFFFFFDF9);
  static const displayLight = Color(0xFFE9DECF);
  static const rackEdgeLight = Color(0xFFD9C9B8);
  static const rackEdgeStrongLight = Color(0xFFB99F88);

  // Signal colours. Green is reserved for "in tune". Flat is a muted slate
  // so it remains distinct from the orange brand and sharp direction.
  static const signalInTune = Color(0xFF8CC59D);
  static const signalFlat = Color(0xFF8EADB5);
  static const signalSharp = Color(0xFFF0A15D);
  static const signalInTuneLight = Color(0xFF35734C);
  static const signalFlatLight = Color(0xFF4F7079);
  static const signalSharpLight = Color(0xFFA84312);

  static const warning = Color(0xFFA8442F);
}
