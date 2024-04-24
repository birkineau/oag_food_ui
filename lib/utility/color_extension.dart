import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color darken([int percent = 10]) {
    assert(percent >= 1 && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * f).round(),
      (green * f).round(),
      (blue * f).round(),
    );
  }

  Color lighten([int percent = 10]) {
    assert(percent >= 1 && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(
      alpha,
      red + ((255 - red) * p).round(),
      green + ((255 - green) * p).round(),
      blue + ((255 - blue) * p).round(),
    );
  }
}
