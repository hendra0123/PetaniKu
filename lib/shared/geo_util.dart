part of 'shared.dart';

class GeoUtil {
  static Future<LatLng> findCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  static num findDistanceBetween(LatLng origin, LatLng target) {
    return Geolocator.distanceBetween(
        origin.latitude, origin.longitude, target.latitude, target.longitude);
  }

// TODO: REPAIR FUNCTION
  static double findMinZoom({
    required List<LatLng> polygon,
    required Size screenSize,
    double tileSize = 256,
  }) {
    if (polygon.isEmpty) return 0;

    // Find the bounding box
    double minLat = polygon.map((p) => p.latitude).reduce(min);
    double maxLat = polygon.map((p) => p.latitude).reduce(max);
    double minLng = polygon.map((p) => p.longitude).reduce(min);
    double maxLng = polygon.map((p) => p.longitude).reduce(max);

    // Map size in pixels with padding
    double width = screenSize.width;
    double height = screenSize.height;

    // Calculate zoom level for width and height
    double latZoom = () {
      double mercatorY(double lat) => log(tan(pi / 4 + degToRadian(lat) / 2));
      double scaleY = height / tileSize;

      return log(scaleY / (mercatorY(maxLat) - mercatorY(minLat))) / ln2;
    }();

    double lngZoom = () {
      double scaleX = width / tileSize;
      return log(scaleX / (maxLng - minLng)) / ln2;
    }();

    return min(latZoom, lngZoom);
  }

  static LatLng findPolygonCenter(List<LatLng> polygon) {
    double x = 0, y = 0, z = 0;

    for (var point in polygon) {
      final latRad = degToRadian(point.latitude);
      final lonRad = degToRadian(point.longitude);

      // Convert to Cartesian coordinates
      x += cos(latRad) * cos(lonRad);
      y += cos(latRad) * sin(lonRad);
      z += sin(latRad);
    }

    final totalPoints = polygon.length;
    x /= totalPoints;
    y /= totalPoints;
    z /= totalPoints;

    z -= 0.000004; // Move slightly to south

    final lon = atan2(y, x);
    final hyp = sqrt(x * x + y * y);
    final lat = atan2(z, hyp);

    return LatLng(radianToDeg(lat), radianToDeg(lon));
  }

  static double findPolygonArea(List<LatLng> polygon) {
    // square meter to hectare
    double area = mp.SphericalUtil.computeArea(_toMPPoints(polygon)) / 10000;
    return double.parse(area.toStringAsFixed(2));
  }

  static List<LatLng> findPolygonBounds(List<LatLng> polygon) {
    double minLat = polygon.map((p) => p.latitude).reduce(min);
    double maxLat = polygon.map((p) => p.latitude).reduce(max);
    double minLng = polygon.map((p) => p.longitude).reduce(min);
    double maxLng = polygon.map((p) => p.longitude).reduce(max);
    return [LatLng(minLat, minLng), LatLng(maxLat, maxLng)];
  }

  static List<LatLng> simplifyPolygon(List<LatLng> polygon) {
    final simplifyPoints = mp.PolygonUtil.simplify(_toMPPoints(polygon), 3);
    return _toLatlongPoints(simplifyPoints);
  }

  static bool isInsidePolygon(List<LatLng> polygon, LatLng point) {
    return mp.PolygonUtil.containsLocation(_toMPPoints([point]).first, _toMPPoints(polygon), false);
  }

  static bool isValidPolygon(List<LatLng> polygon) {
    if (polygon.length < 4 || polygon.first != polygon.last) {
      return false;
    }

    // Check if there is intersecting sides
    for (int i = 0; i < polygon.length - 1; i++) {
      for (int j = i + 2; j < polygon.length - 1; j++) {
        // Skip adjacent edges
        if (i == 0 && j == polygon.length - 2) continue;

        if (_doEdgesIntersect(
          polygon[i],
          polygon[i + 1],
          polygon[j],
          polygon[j + 1],
        )) {
          return false; // Found intersecting sides
        }
      }
    }
    return true; // No intersections found
  }

  static bool _doEdgesIntersect(LatLng a, LatLng b, LatLng c, LatLng d) {
    // Helper to check orientation of triplet (p, q, r)
    int orientation(LatLng p, LatLng q, LatLng r) {
      double value = (q.latitude - p.latitude) * (r.longitude - q.longitude) -
          (q.longitude - p.longitude) * (r.latitude - q.latitude);
      if (value == 0) return 0; // Collinear
      return (value > 0) ? 1 : 2; // Clockwise or Counterclockwise
    }

    // Check if point q lies on segment pr
    bool onSegment(LatLng p, LatLng q, LatLng r) {
      return q.latitude <= max(p.latitude, r.latitude) &&
          q.latitude >= min(p.latitude, r.latitude) &&
          q.longitude <= max(p.longitude, r.longitude) &&
          q.longitude >= min(p.longitude, r.longitude);
    }

    // Find orientations
    int o1 = orientation(a, b, c);
    int o2 = orientation(a, b, d);
    int o3 = orientation(c, d, a);
    int o4 = orientation(c, d, b);

    // General case
    if (o1 != o2 && o3 != o4) return true;

    // Special cases: Check if points are collinear and overlap
    if (o1 == 0 && onSegment(a, c, b)) return true;
    if (o2 == 0 && onSegment(a, d, b)) return true;
    if (o3 == 0 && onSegment(c, a, d)) return true;
    if (o4 == 0 && onSegment(c, b, d)) return true;

    return false; // No intersection
  }

  static List<mp.LatLng> _toMPPoints(List<LatLng> points) {
    final List<mp.LatLng> convertedPoints = [];
    for (var point in points) {
      final convertedPoint = mp.LatLng(point.latitude, point.longitude);
      convertedPoints.add(convertedPoint);
    }
    return convertedPoints;
  }

  static List<LatLng> _toLatlongPoints(List<mp.LatLng> points) {
    final List<LatLng> reverseConvertedPoints = [];
    for (var point in points) {
      final convertedPoint = LatLng(point.latitude, point.longitude);
      reverseConvertedPoints.add(convertedPoint);
    }
    return reverseConvertedPoints;
  }
}
