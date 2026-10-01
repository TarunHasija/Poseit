import 'package:flutter/material.dart';

abstract final class AppRadii {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double full = 999;

  static const BorderRadius small = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(md));
  static const BorderRadius large = BorderRadius.all(Radius.circular(lg));
}
