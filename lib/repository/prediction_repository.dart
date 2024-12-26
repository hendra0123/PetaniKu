part of 'repository.dart';

class PredictionRepository {
  final String prefixEndpoint = "/user/predictions";

  Future<List<History>> fetchHistories() async {
    try {
      dynamic response = await apiServices.getJSONRequest(prefixEndpoint);
      return (response as List).map((e) => History.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Prediction> fetchPrediction(String predictionId) async {
    try {
      dynamic response = await apiServices.getJSONRequest("$prefixEndpoint/$predictionId");
      return Prediction.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Prediction> createPrediction(String season, String plantingType, num paddyAge,
      List<LatLng> coordinates, List<String> imagePaths) async {
    final payload = {
      "season": season,
      "planting_type": plantingType,
      "paddy_age": paddyAge,
      "coordinates": coordinates.map((coordinate) {
        return {"latitude": coordinate.latitude, "longitude": coordinate.longitude};
      }).toList(),
    };
    final imageFiles = imagePaths.map((path) {
      return {'key': 'images', 'path': path, 'mimeType': 'image', 'subtype': 'jpeg'};
    }).toList();
    try {
      dynamic response =
          await apiServices.postMultipartRequest(prefixEndpoint, payload, imageFiles);
      return Prediction.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
