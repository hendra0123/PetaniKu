part of 'view_model.dart';

class HistoryViewModel extends ChangeNotifier {
  final PredictionRepository _predictionRepo = PredictionRepository();
  ApiResponse<List<History>> _response = ApiResponse.notStarted();

  List<History>? get history => _response.data;
  Status? get status => _response.status;

  bool get isHistoryPresent => history != null && history!.isNotEmpty;

  void setApiResponse(ApiResponse<List<History>> result) {
    _response = result;
    notifyListeners();
  }

  Future<void> getHistory() async {
    if (!hasDataChanged || status == Status.loading) return;

    setApiResponse(ApiResponse.loading());
    try {
      List<History> historyData = await _predictionRepo.fetchHistory();
      hasDataChanged = false;
      setApiResponse(ApiResponse.completed(historyData));
    } catch (error) {
      setApiResponse(ApiResponse.error(error.toString()));
    }
  }
}
