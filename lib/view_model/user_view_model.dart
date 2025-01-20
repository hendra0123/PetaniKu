part of 'view_model.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepo = UserRepository();
  ApiResponse<User> _response = ApiResponse.notStarted();

  User? get user => _response.data;
  Summary? get summary => _response.data?.summary;
  String? get plantingType => _response.data?.summary?.plantingType;
  List<RiceLeaf>? get riceLeaves => _response.data?.summary?.riceLeaves;
  List<Statistic>? get statisic => _response.data?.summary?.statistic;
  RiceField? get riceField => _response.data?.riceField;
  Status? get status => _response.status;

  bool get isRiceFieldPolygonPresent =>
      riceField != null && riceField!.polygon != null && riceField!.polygon!.isNotEmpty;

  void setApiResponse(ApiResponse<User> result) {
    _response = result;
    notifyListeners();
  }

  Future<void> getUserData() async {
    if (!hasDataChanged || status == Status.loading) return;

    setApiResponse(ApiResponse.loading());
    try {
      User userData = await _userRepo.fetchDashboard();
      hasDataChanged = false;
      setApiResponse(ApiResponse.completed(userData));
    } catch (error) {
      setApiResponse(ApiResponse.error(error.toString()));
    }
  }

  Future<String> updateRiceField(RiceField field) async {
    if (field.polygon == null || field.area == null) {
      return "Koordinat dan luas tidak boleh kosong";
    }

    User? currentUser = user;
    setApiResponse(ApiResponse.loading());
    try {
      String message = await _userRepo.saveRiceField(field.polygon!, field.area!);
      hasDataChanged = true;
      if (currentUser != null) {
        setApiResponse(ApiResponse.completed(currentUser.copyWith(riceField: field)));
      } else {
        setApiResponse(ApiResponse.completed(User(riceField: field)));
      }
      return message;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String> postLogin(String phone) async {
    setApiResponse(ApiResponse.loading());
    try {
      String message = await _userRepo.login(phone);
      hasDataChanged = true;
      setApiResponse(ApiResponse.notStarted());
      return message;
    } catch (error) {
      setApiResponse(ApiResponse.notStarted());
      return Future.error(error.toString());
    }
  }

  Future<String> postRegister(String name, String phone) async {
    setApiResponse(ApiResponse.loading());
    try {
      String message = await _userRepo.register(name, phone);
      hasDataChanged = true;
      setApiResponse(ApiResponse.notStarted());
      return message;
    } catch (error) {
      setApiResponse(ApiResponse.notStarted());
      return Future.error(error.toString());
    }
  }
}
