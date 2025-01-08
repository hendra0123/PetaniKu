part of 'shared.dart';

class AppConstant {
  static const double defaultInitialZoom = 19;

  static const LatLng defaultInitialPosition = LatLng(-5.149333, 119.395184);

  static const String baseUrl = "https://b29q2kft-5000.asse.devtunnels.ms/";

  static String authentication =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiUExXdmtoN1h4NW1ITFl2WEhPZFUiLCJleHAiOjE3MzYzOTMxNTksImlhdCI6MTczNjMwNjc1OX0.RETZbQjNzbogZxojDVnc36K2tZgekhUtuM9lF-Wn-NA";

  static TileLayer get openStreeMapTileLayer =>
      TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png");

  static TileLayer get mapTilerSatelliteTileLayer => TileLayer(
        urlTemplate: "https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.jpg?key={apiKey}",
        additionalOptions: <String, String>{"apiKey": dotenv.env['MAPTILER_API_KEY'] ?? ""},
      );
}
