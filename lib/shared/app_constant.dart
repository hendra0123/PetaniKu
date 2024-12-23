part of 'shared.dart';

class AppConstant {
  static TileLayer get openStreeMapTileLayer =>
      TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png");

  static TileLayer get mapTilerSatelliteTileLayer => TileLayer(
        urlTemplate: "https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.jpg?key={apiKey}",
        additionalOptions: <String, String>{"apiKey": "${dotenv.env['MAPTILER_API_KEY']}"},
      );

  static Position get initialPosition => Position(
        latitude: -5.149333,
        longitude: 119.395184,
        timestamp: DateTime.now(),
        altitudeAccuracy: 5.0,
        headingAccuracy: 5.0,
        altitude: 30.0,
        accuracy: 5.0,
        heading: 90.0,
        speed: 2.5,
        speedAccuracy: 0.5,
      );
}
