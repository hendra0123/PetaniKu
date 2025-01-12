part of "shared.dart";

class PolygonGenerator {
  /// Generate circle polygon for single point by certain radius
  List<LatLng> circlePolygon(LatLng point, double radius, List<LatLng> boundaryPoints) {
    const int numberOfPoints = 36;
    const double angleIncrement = 360.0 / numberOfPoints;
    final double angularDistance = radius / earthRadius;

    final List<LatLng> polygonPoints = List.generate(numberOfPoints, (index) {
      final double bearing = degToRadian(index * angleIncrement);
      final double lat1 = point.latitudeInRad;
      final double lon1 = point.longitudeInRad;

      final double lat2 = asin(
        sin(lat1) * cos(angularDistance) + cos(lat1) * sin(angularDistance) * cos(bearing),
      );

      final double lon2 = lon1 +
          atan2(
            sin(bearing) * sin(angularDistance) * cos(lat1),
            cos(angularDistance) - sin(lat1) * sin(lat2),
          );

      return LatLng(radianToDeg(lat2), radianToDeg(lon2));
    });

    return _suthHodgClip(polygonPoints, boundaryPoints);
  }

  /// Generate a rounded-box polygon for multiple points with a buffer distance
  List<LatLng> roundedBoxPolygon(
      List<LatLng> points, double bufferMeters, List<LatLng> boundaryPoints) {
    double minLat = points.map((p) => p.latitude).reduce(min);
    double maxLat = points.map((p) => p.latitude).reduce(max);
    double minLng = points.map((p) => p.longitude).reduce(min);
    double maxLng = points.map((p) => p.longitude).reduce(max);

    final List<LatLng> polygonPoints = [
      ..._generateArc(LatLng(maxLat, maxLng), 0, 90, bufferMeters),
      ..._generateArc(LatLng(minLat, maxLng), 90, 180, bufferMeters),
      ..._generateArc(LatLng(minLat, minLng), 180, 270, bufferMeters),
      ..._generateArc(LatLng(maxLat, minLng), 270, 360, bufferMeters),
    ];

    if (boundaryPoints.last == boundaryPoints.first) boundaryPoints.removeLast();

    return _suthHodgClip(polygonPoints, boundaryPoints);
  }

  /// Generate a quarter-circle arc for rounded corners
  List<LatLng> _generateArc(
      LatLng center, double startAngle, double endAngle, double radiusMeters) {
    const double arcStepDegrees = 5.0;
    return List.generate(((endAngle - startAngle) / arcStepDegrees).ceil() + 1, (index) {
      final double angle = startAngle + index * arcStepDegrees;
      final double radian = degToRadian(angle);
      final double latOffset = radiusMeters * cos(radian);
      final double lngOffset = radiusMeters * sin(radian);
      return _offsetLatLng(center, latOffset, lngOffset);
    });
  }

  /// Offset a LatLng by given distances in meters (north/south and east/west)
  LatLng _offsetLatLng(LatLng point, double northMeters, double eastMeters) {
    final double dLat = northMeters / earthRadius;
    final double dLng = eastMeters / (earthRadius * cos(degToRadian(point.latitude)));
    return LatLng(point.latitude + radianToDeg(dLat), point.longitude + radianToDeg(dLng));
  }

  /// Clips polygon using Sutherland–Hodgman algorithm
  List<LatLng> _suthHodgClip(List<LatLng> polyPoints, List<LatLng> clipperPoints) {
    polyPoints = _isClockwise(polyPoints) ? polyPoints.reversed.toList() : polyPoints;
    clipperPoints = _isClockwise(clipperPoints) ? clipperPoints.reversed.toList() : clipperPoints;

    for (int i = 0; i < clipperPoints.length; i++) {
      final int k = (i + 1) % clipperPoints.length;
      polyPoints = _clip(polyPoints, clipperPoints[i], clipperPoints[k]);
    }
    return polyPoints;
  }

  /// Checks if the given points is clockwise
  bool _isClockwise(List<LatLng> points) {
    return points.fold<double>(0, (sum, point) {
          final int index = points.indexOf(point);
          final LatLng nextPoint = points[(index + 1) % points.length];
          return sum +
              (nextPoint.longitude - point.longitude) * (nextPoint.latitude + point.latitude);
        }) >
        0;
  }

  /// Clips all edges w.r.t one clip edge of the clipping area
  List<LatLng> _clip(List<LatLng> polyPoints, LatLng clipStart, LatLng clipEnd) {
    List<LatLng> newPoints = [];
    for (int i = 0; i < polyPoints.length; i++) {
      int k = (i + 1) % polyPoints.length;
      LatLng current = polyPoints[i];
      LatLng next = polyPoints[k];

      double iPos =
          (clipEnd.latitude - clipStart.latitude) * (current.longitude - clipStart.longitude) -
              (clipEnd.longitude - clipStart.longitude) * (current.latitude - clipStart.latitude);

      double kPos =
          (clipEnd.latitude - clipStart.latitude) * (next.longitude - clipStart.longitude) -
              (clipEnd.longitude - clipStart.longitude) * (next.latitude - clipStart.latitude);

      // Case 1: Both points are inside
      if (iPos < 0 && kPos < 0) {
        newPoints.add(next);
      }
      // Case 2: First point is outside, second is inside
      else if (iPos >= 0 && kPos < 0) {
        newPoints.add(LatLng(_xIntersect(clipStart, clipEnd, current, next),
            _yIntersect(clipStart, clipEnd, current, next)));
        newPoints.add(next);
      }
      // Case 3: First point is inside, second is outside
      else if (iPos < 0 && kPos >= 0) {
        newPoints.add(LatLng(_xIntersect(clipStart, clipEnd, current, next),
            _yIntersect(clipStart, clipEnd, current, next)));
      }
      // Case 4: Both points are outside (do nothing)
    }
    return newPoints;
  }

  /// Returns x-value of point of intersection of two lines
  double _xIntersect(LatLng p1, LatLng p2, LatLng q1, LatLng q2) {
    final double num =
        (p1.latitude * p2.longitude - p1.longitude * p2.latitude) * (q1.latitude - q2.latitude) -
            (p1.latitude - p2.latitude) * (q1.latitude * q2.longitude - q1.longitude * q2.latitude);
    final double den = (p1.latitude - p2.latitude) * (q1.longitude - q2.longitude) -
        (p1.longitude - p2.longitude) * (q1.latitude - q2.latitude);
    return num / den;
  }

  /// Returns y-value of point of intersection of two lines
  double _yIntersect(LatLng p1, LatLng p2, LatLng q1, LatLng q2) {
    final double num = (p1.latitude * p2.longitude - p1.longitude * p2.latitude) *
            (q1.longitude - q2.longitude) -
        (p1.longitude - p2.longitude) * (q1.latitude * q2.longitude - q1.longitude * q2.latitude);
    final double den = (p1.latitude - p2.latitude) * (q1.longitude - q2.longitude) -
        (p1.longitude - p2.longitude) * (q1.latitude - q2.latitude);
    return num / den;
  }
}
