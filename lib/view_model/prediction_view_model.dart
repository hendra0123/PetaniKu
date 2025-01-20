part of 'view_model.dart';

class PredictionViewModel extends ChangeNotifier {
  final PredictionRepository _predictionRepo = PredictionRepository();
  ApiResponse<Prediction> _response = ApiResponse.notStarted();

  Prediction? get prediction => _response.data;
  String? get message => _response.message;
  Status? get status => _response.status;

  void setApiResponse(ApiResponse<Prediction> result) {
    _response = result;
    notifyListeners();
  }

  Future<void> getPrediction(String predictionId) async {
    setApiResponse(ApiResponse.loading());
    try {
      Prediction predictionData = await _predictionRepo.fetchPrediction(predictionId);
      setApiResponse(ApiResponse.completed(predictionData));
    } catch (error) {
      setApiResponse(ApiResponse.error(error.toString()));
    }
  }

  Future<void> postPrediction(String season, String plantingType, int paddyAge, List<File> images,
      List<LatLng> points) async {
    setApiResponse(ApiResponse.loading());
    try {
      Prediction predictionData =
          await _predictionRepo.createPrediction(season, plantingType, paddyAge, images, points);
      hasDataChanged = true;
      setApiResponse(ApiResponse.completed(predictionData));
    } catch (error) {
      setApiResponse(ApiResponse.error(error.toString()));
    }
  }
}
