import 'dart:math' as math;

import 'pair.dart';

class MathExtension {
  static double degreesToRadians(double degrees) => degrees * math.pi / 180.0;
  static double radiansToDegrees(double radians) => radians * 180.0 / math.pi;

  static int lcm(int a, int b) {
    int temp = gcd(a, b);

    return temp != 0 ? (a ~/ temp * b) : 0;
  }

  static int listLcm(List<int> values) {
    return values.fold<int>(1, (fold, value) => MathExtension.lcm(fold, value));
  }

  static int gcd(int a, int b) {
    for (;;) {
      if (a == 0) return b;
      b %= a;
      if (b == 0) return a;
      a %= b;
    }
  }

  /// https://github.com/albertodev01/fraction/blob/master/lib/src/types/standard.dart
  static Pair<int, int> doubleToFraction(
    double value, {
    double precision = 1.0e-12,
  }) {
    // Storing the sign
    final abs = value.abs();
    final mul = (value >= 0) ? 1 : -1;
    final x = abs;

    // How many digits is the algorithm going to consider
    final limit = precision;
    var h1 = 1;
    var h2 = 0;
    var k1 = 0;
    var k2 = 1;
    var y = abs;

    do {
      final a = y.floor();
      var aux = h1;
      h1 = a * h1 + h2;
      h2 = aux;
      aux = k1;
      k1 = a * k1 + k2;
      k2 = aux;
      y = 1 / (y - a);
    } while ((x - h1 / k1).abs() > x * limit);

    return Pair(first: (mul * h1).toInt(), second: k1);
  }
}
