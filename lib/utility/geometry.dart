import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

bool circlesIntersect(
  double x0,
  double y0,
  double r0,
  double x1,
  double y1,
  double r1,
) {
  final dx = x0 - x1;
  final dy = y0 - y1;

  /// The distance between the center of the two circles.
  final distance = math.sqrt(dx * dx + dy * dy);

  /// The minimum distance of two non-overlapping circles is the sum of their
  /// radii.
  final minimumDistance = r0 + r1;

  /// The circles intersect if the distance between their centers is less than
  /// or equal to the sum of their radii; [minimumDistance].
  return distance <= minimumDistance;
}

/// Calculate the intersection point between two lines.
Vector2 intersectionPoint(
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3,
  double x4,
  double y4,
) {
  final x =
      ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) /
          ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
  final y =
      ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) /
          ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));

  return Vector2(x, y);
}

/// Calculate the angle between two directional vectors.
///
/// To find the angle between two directional vectors, you can use the dot
/// product formula. The dot product of two vectors is equal to the magnitude
/// of the vectors multiplied by the cosine of the angle between them.
///
/// a · b = ||a|| * ||b|| * cos(θ)
///
/// Where ||a|| and ||b|| are the magnitudes of vectors a and b, and θ is the
/// angle between a and b. To find θ, you can use the following formula:
///
/// θ = arccos((a · b) / (||a|| * ||b||))
double angleBetweenVectors(double x1, double y1, double x2, double y2) {
  final a = Vector2(x1, y1);
  final b = Vector2(x2, y2);
  final dotProduct = a.dot(b);
  final magnitude = a.length * b.length;
  final angle = math.acos(dotProduct / magnitude);
  return angle;
}

/// To find the directional vector composed of two points, you can subtract the
/// initial point from the terminal point to obtain a vector that starts at the
/// initial point and ends at the terminal point.
///
/// Let `A` and `B` be two points in n-dimensional space with coordinates `(x1,
/// x2, ..., xn)` and `(y1, y2, ..., yn)` respectively. Then, the directional
/// vector AB from A to B is given by:
///
/// `AB = (y1 - x1, y2 - x2, ..., yn - xn)`
///
/// Note that this vector is not necessarily of unit length (i.e., its magnitude
/// may not equal 1). To obtain a unit vector in the same direction, you can
/// divide the vector by its magnitude.
Vector2 directionVector(double x1, double y1, double x2, double y2) =>
    Vector2(x2, y2) - Vector2(x1, y1);

/// To find the length of a line segment composed of two points in a
/// n-dimensional space, you can use the distance formula.
///
/// Let `A` and `B` be two points with coordinates `(x1, x2, ..., xn)` and
/// `(y1, y2, ..., yn)` respectively. Then, the length of the line segment AB
/// is given by:
///
/// `d(AB) = √((y1 - x1)^2 + (y2 - x2)^2 + ... + (yn - xn)^2)`
///
/// In other words, the length of the line segment is the square root of the
/// sum of the squares of the differences of the coordinates of the two points.
double distanceBetweenPoints(double x1, double y1, double x2, double y2) {
  final dx = x2 - x1;
  final dy = y2 - y1;
  return math.sqrt(dx * dx + dy * dy);
}

List<Placement> findPlacements({
  required Size size,
  double padding = .0,
  required Circle circle,
  required double orbiterRadius,
  double step = 0.0174533,
  List<Circle> circlesToAvoid = const [],
}) {
  final List<Placement> placements = [];
  var flag = true;

  for (var angle = .0; angle < 2.0 * math.pi; angle += step) {
    final x = circle.center.dx +
        (circle.radius + padding + orbiterRadius) * math.cos(angle);
    final y = circle.center.dy +
        (circle.radius + padding + orbiterRadius) * math.sin(angle);

    if (circlesToAvoid.any(
      (c) => circlesIntersect(
        c.center.dx,
        c.center.dy,
        c.radius + padding,
        x,
        y,
        orbiterRadius,
      ),
    )) {
      continue;
    }

    bool isInside() =>
        x - orbiterRadius >= .0 &&
        y - orbiterRadius >= .0 &&
        x + orbiterRadius <= size.width &&
        y + orbiterRadius <= size.height;

    if (flag) {
      if (isInside()) {
        placements.add(Placement(Offset(x, y), angle));
        flag = false;
      }
    } else {
      if (!isInside()) {
        placements.add(Placement(Offset(x, y), angle));
        flag = true;
      }
    }
  }

  return placements;
}

const radii = [
  48.0 + 16 * 0,
  48.0 + 16 * 1,
  48.0 + 16 * 2,
  48.0 + 16 * 3,
];

/// Find the available space from any one circle.
/// I must pick one circle, and check how much space there is at each edge
EdgeInsets findAvailableSpace({
  required Size size,
  required Circle circle,
  required double orbiterRadius,
  double padding = .0,
  List<Circle> circlesToAvoid = const [],
}) {
  final top = circle.center.dy - circle.radius - orbiterRadius - padding;
  final bottom = size.height - circle.center.dy - circle.radius - orbiterRadius;
  final left = circle.center.dx - circle.radius - orbiterRadius - padding;
  final right = size.width - circle.center.dx - circle.radius - orbiterRadius;

  return EdgeInsets.fromLTRB(left, top, right, bottom);
}

CData generateCircles(Size size, [double padding = .0]) {
  final circles = <Circle>[];

  /// Select a random radius.
  var orbitRadius = radii.random();
  var centerDx =
      math.Random().nextInt((size.width - orbitRadius).toInt()).toDouble();

  /// Remain within the bounds of the rectangle.
  if (centerDx - orbitRadius < .0) centerDx = orbitRadius;
  var orbitCenter = Offset(centerDx, orbitRadius);

  /// Add the first circle.
  var circle = Circle(orbitCenter, orbitRadius);
  circles.add(circle);

  /// Select a random radius for the circle i.
  var orbiterRadius = radii.random();
  var placements = findPlacements(
    size: size,
    padding: padding,
    circle: circle,
    orbiterRadius: orbiterRadius,
    circlesToAvoid: circles,
  );

  var indexOfLowest = 0;
  var lowestCircle = circles.first;
  var availableSpace =
      size.height - lowestCircle.center.dy - lowestCircle.radius;

  while (availableSpace - orbiterRadius >= 0) {
    if (placements.isEmpty) {
      circle = lowestCircle;
      placements = findPlacements(
        size: size,
        padding: padding,
        circle: circle,
        orbiterRadius: orbiterRadius,
        circlesToAvoid: circles,
      );

      if (placements.isEmpty) break;
    }

    var orbiterCircle = Circle(placements.first.offset, orbiterRadius);
    circles.add(orbiterCircle);

    orbiterRadius = radii.random();
    placements = findPlacements(
      size: size,
      padding: padding,
      circle: circle,
      orbiterRadius: orbiterRadius,
      circlesToAvoid: circles,
    );

    for (var i = indexOfLowest; i < circles.length; ++i) {
      final circle = circles[i];
      if (lowestCircle.center.dy < circle.center.dy) {
        indexOfLowest = i;
        lowestCircle = circle;
      }
    }

    availableSpace = size.height - lowestCircle.center.dy - lowestCircle.radius;
  }

  List<Circle> reversePassCircles = [];
  /*
  void reversePass() {
    final surroundingCircles = reversePassCircles.isEmpty
        ? findSurroundingCircles(circles)
        : reversePassCircles;

    var circleIndex = surroundingCircles.length - 1;

    /// Iterate circles in reverse to fill empty space.
    for (; circleIndex >= 0;) {
      // orbiterRadius = radii.random();
      final circle = surroundingCircles[circleIndex];

      final placements = findPlacements(
        size: size,
        padding: padding,
        circle: circle,
        orbiterRadius: orbiterRadius,
        circlesToAvoid: circles,
      );

      final radiusIndex = radii.indexOf(orbiterRadius);

      /// To find even more circles, decrease the orbiter radius if no
      /// placements are found and there are smaller radii; stop when the
      /// smallest radius is reached.
      if (placements.isEmpty && radiusIndex > 0) {
        orbiterRadius = radii[radiusIndex - 1];
        continue;
      }

      if (placements.isNotEmpty) {
        final orbiterCircle = Circle(placements.first.offset, orbiterRadius);
        circles.add(orbiterCircle);
        reversePassCircles.add(circle);
        continue;
      }

      orbiterRadius = radii.last;
      --circleIndex;
    }
  }

  for (var i = 0; i < 8; ++i) {
    log("bounding box = ${getBoundingBox(reversePassCircles)}");

    reversePass();
  }
  */
  //*
  void reversePass() {
    final inputCircles =
        reversePassCircles.isEmpty ? circles : reversePassCircles;
    var circleIndex = inputCircles.length - 1;

    /// Iterate circles in reverse to fill empty space.
    for (; circleIndex >= 0;) {
      // orbiterRadius = radii.random();
      final circle = inputCircles[circleIndex];

      final placements = findPlacements(
        size: size,
        padding: padding,
        circle: circle,
        orbiterRadius: orbiterRadius,
        circlesToAvoid: circles,
      );

      final radiusIndex = radii.indexOf(orbiterRadius);

      /// To find even more circles, decrease the orbiter radius if no
      /// placements are found and there are smaller radii; stop when the
      /// smallest radius is reached.
      if (placements.isEmpty && radiusIndex > 0) {
        orbiterRadius = radii[radiusIndex - 1];
        continue;
      }

      if (placements.isNotEmpty) {
        final orbiterCircle = Circle(placements.first.offset, orbiterRadius);
        circles.add(orbiterCircle);
        reversePassCircles.add(orbiterCircle);
        continue;
      }

      orbiterRadius = radii.last;
      --circleIndex;
    }
  }

  for (var i = 0; i < 8; ++i) {
    reversePass();
  }

  for (var i = 0; i < circles.length; ++i) {
    final circle = circles[i];
    if (lowestCircle.center.dy < circle.center.dy) {
      indexOfLowest = i;
      lowestCircle = circle;
    }
  }

  assert(circles.isNotEmpty);

  final boundingBox = getBoundingBox(circles);

  /// The center of the rectangle.
  final dx = (size.width - boundingBox.width) / 2.0;
  final dy = (size.height - boundingBox.height) / 2.0;

  /// Translate the circles to the center of the rectangle.
  for (var i = 0; i < circles.length; ++i) {
    final circle = circles[i];
    circles[i] = Circle(
      Offset(
        circle.center.dx + dx - boundingBox.left,
        circle.center.dy + dy - boundingBox.top,
      ),
      circle.radius,
    );
  }

  return CData(circles, Offset(dx, dy) & boundingBox.size);
}

class Placement {
  const Placement(this.offset, this.angle);

  final Offset offset;
  final double angle;

  @override
  String toString() => "Placement(offset: $offset, angle: $angle)";
}

class Circle {
  static const zero = Circle(Offset.zero, .0);

  const Circle(this.center, this.radius);

  final Offset center;
  final double radius;

  @override
  String toString() => "Circle(center: $center, radius: $radius)";
}

extension ListExtension<T> on List<T> {
  static final _random = math.Random();

  T random() => this[_random.nextInt(length)];
  T removeRandom() => removeAt(_random.nextInt(length));
}

class CData {
  static const zero = CData([], Rect.zero);

  const CData(this.circles, this.boundingBox);

  final List<Circle> circles;
  final Rect boundingBox;
}

Rect getBoundingBox(List<Circle> circles) {
  if (circles.isEmpty) return Rect.zero;

  var top = circles.first;
  var bottom = circles.first;
  var left = circles.first;
  var right = circles.first;

  /// Find the bounding box top, bottom, left, and right.
  for (var i = 1; i < circles.length; ++i) {
    final circle = circles[i];

    if (top.center.dy - top.radius > circle.center.dy - circle.radius) {
      top = circle;
    }

    if (bottom.center.dy + bottom.radius < circle.center.dy + circle.radius) {
      bottom = circle;
    }

    if (left.center.dx - left.radius > circle.center.dx - circle.radius) {
      left = circle;
    }

    if (right.center.dx + right.radius < circle.center.dx + circle.radius) {
      right = circle;
    }
  }

  final totalWidth =
      (right.center.dx + right.radius) - (left.center.dx - left.radius);

  final totalHeight =
      (bottom.center.dy + bottom.radius) - (top.center.dy - top.radius);

  /// Since this algorithm always places the first circle at the top, the
  /// bounding box's dy is always 0.
  return Rect.fromLTWH(
    left.center.dx - left.radius,
    top.center.dy - top.radius,
    totalWidth,
    totalHeight,
  );
}

List<Circle> findSurroundingCircles(List<Circle> circles) =>
    monotoneChainConvexHull<Circle>(
      circles,
      (e) => e.center.dx,
      (e) => e.center.dy,
    ).toList(growable: false);

List<T> monotoneChainConvexHull<T>(
  List<T> points,
  double Function(T) getX,
  double Function(T) getY,
) {
  if (points.length < 3) return points;

  points.sort(
    (a, b) {
      int cmp = getX(a).compareTo(getX(b));
      return cmp == 0 ? getY(a).compareTo(getY(b)) : cmp;
    },
  );

  List<T> hull = [];

  void addToHull(T point) {
    while (hull.length >= 2) {
      T last = hull.last;
      T secondLast = hull[hull.length - 2];
      if ((getX(point) - getX(secondLast)) * (getY(last) - getY(secondLast)) -
              (getY(point) - getY(secondLast)) *
                  (getX(last) - getX(secondLast)) <=
          0) {
        hull.removeLast();
      } else {
        break;
      }
    }
    hull.add(point);
  }

  for (final point in points) {
    addToHull(point);
  }

  int upperHullSize = hull.length;

  for (int i = points.length - 2; i >= 0; i--) {
    final point = points[i];
    addToHull(point);
  }

  hull.removeLast();
  if (hull.length == upperHullSize) {
    hull.removeAt(0);
  }

  return hull;
}
