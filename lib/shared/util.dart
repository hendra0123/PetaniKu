part of 'shared.dart';

class Util {
  static Future<Position> findCurrentPosition() async {
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

    return await Geolocator.getCurrentPosition();
  }

  static LatLng findPolygonCenter(List<LatLng> points) {
    double x = 0, y = 0, z = 0;

    for (var point in points) {
      final latRad = point.latitude * pi / 180;
      final lonRad = point.longitude * pi / 180;

      // Convert to Cartesian coordinates
      x += cos(latRad) * cos(lonRad);
      y += cos(latRad) * sin(lonRad);
      z += sin(latRad);
    }

    final totalPoints = points.length;
    x /= totalPoints;
    y /= totalPoints;
    z /= totalPoints;

    final lon = atan2(y, x);
    final hyp = sqrt(x * x + y * y);
    final lat = atan2(z, hyp);

    return LatLng(lat * 180 / pi, lon * 180 / pi);
  }

  static num findDistanceBetween(LatLng origin, LatLng target) {
    // Convert latlong2 to Maps Toolkit
    final originCoord = mp.LatLng(origin.latitude, origin.longitude);
    final targetCoord = mp.LatLng(target.latitude, target.longitude);
    return mp.SphericalUtil.computeDistanceBetween(originCoord, targetCoord);
  }

  static bool checkPolygon(List<LatLng> polygonPoints) {
    final List<mp.LatLng> convertedPolygonPoints = [];
    for (var point in polygonPoints) {
      final convertedPoint = mp.LatLng(point.latitude, point.longitude);
      convertedPolygonPoints.add(convertedPoint);
    }
    return mp.PolygonUtil.isClosedPolygon(convertedPolygonPoints);
  }
}
