part of 'shared.dart';

class AppConstant {
  static const double defaultInitialZoom = 18;

  static const LatLng defaultInitialPosition = LatLng(-5.149333, 119.395184);

  static const String baseUrl = "https://b29q2kft-5000.asse.devtunnels.ms/";

  static String authentication = "";

  static CameraDescription cameraDesc = const CameraDescription(
    name: 'default',
    lensDirection: CameraLensDirection.back,
    sensorOrientation: 0,
  );

  static TileLayer get openStreeMapTileLayer =>
      TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png");

  static TileLayer get mapTilerSatelliteTileLayer => TileLayer(
        urlTemplate: "https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.jpg?key={apiKey}",
        additionalOptions: <String, String>{"apiKey": dotenv.env['MAPTILER_API_KEY'] ?? ""},
      );
}
