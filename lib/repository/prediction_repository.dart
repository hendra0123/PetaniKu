part of 'repository.dart';

class PredictionRepository {
  final String prefixEndpoint = "/user/predictions";

  Future<List<History>> fetchHistory() async {
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

  Future<Prediction> createPrediction(String season, String plantingType, int paddyAge,
      List<File> images, List<LatLng> points) async {
    final payload = {
      "season": season,
      "planting_type": plantingType,
      "paddy_age": paddyAge,
      "points": points.map((point) => [point.latitude, point.longitude]).toList(),
    };
    final imageData = images.map((img) {
      final mimeType = lookupMimeType(img.path);
      return {
        'key': 'images',
        'path': img.path,
        'mimeType': mimeType?.split('/')[0] ?? 'image',
        'subtype': mimeType?.split('/')[1] ?? 'jpeg',
      };
    }).toList();
    try {
      dynamic response = await apiServices.postMultipartRequest(prefixEndpoint, payload, imageData);
      return Prediction.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
