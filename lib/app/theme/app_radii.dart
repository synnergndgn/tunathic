import 'package:flutter/material.dart';

abstract final class AppRadii {
  static const small = Radius.circular(6);
  static const medium = Radius.circular(10);

  static const smallBorder = BorderRadius.all(small);
  static const mediumBorder = BorderRadius.all(medium);
}
