import 'package:flutter/material.dart';

/// The corner scale.
///
/// Deliberately tight: at these radii a panel reads as a machined face plate
/// rather than a web card, which is the whole point of the rack metaphor.
/// Only literally circular things (status LEDs, knobs) stay round, and they
/// ask for a circle rather than for a radius.
abstract final class AppRadii {
  static const small = Radius.circular(2);
  static const medium = Radius.circular(3);
  static const large = Radius.circular(4);

  /// The corner of a rack unit or a tuner display.
  static const device = Radius.circular(6);

  static const smallBorder = BorderRadius.all(small);
  static const mediumBorder = BorderRadius.all(medium);
  static const largeBorder = BorderRadius.all(large);
  static const deviceBorder = BorderRadius.all(device);

  /// Was a true pill. Kept as a named role so the chips and readouts that
  /// asked for one still have somewhere to point, but it no longer rounds
  /// them off — nothing in the system is pill-shaped any more.
  static const pillBorder = BorderRadius.all(medium);
}

typedef TunathicRadii = AppRadii;
