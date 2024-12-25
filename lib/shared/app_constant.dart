part of 'shared.dart';

class AppConstant {
  static TileLayer get openStreeMapTileLayer =>
      TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png");

  static TileLayer get mapTilerSatelliteTileLayer => TileLayer(
        urlTemplate:
            "https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.jpg?key={apiKey}",
        additionalOptions: <String, String>{
          "apiKey": "${dotenv.env['MAPTILER_API_KEY']}"
        },
      );

  static LatLng get defaultInitialPosition =>
      const LatLng(-5.149333, 119.395184);

  static double get defaultInitialZoom => 19;
}
