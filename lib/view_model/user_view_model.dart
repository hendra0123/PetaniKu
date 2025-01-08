part of 'view_model.dart';

class UserViewModel extends ChangeNotifier {
  static final UserViewModel _instance = UserViewModel._internal(UserRepository());
  factory UserViewModel() => _instance;
  UserViewModel._internal(this._userRepo);

  final UserRepository _userRepo;
  ApiResponse<User> _response = ApiResponse.notStarted();
  bool _hasDataChanged = true;

  User? get user => _response.data;
  RiceField? get riceField => _response.data?.riceField;
  Summary? get summary => _response.data?.summary;
  Status? get status => _response.status;

  void setApiResponse(ApiResponse<User> result) {
    _response = result;
    notifyListeners();
  }

  Future<void> getUserData() async {
    if (!_hasDataChanged || status == Status.loading) return;

    setApiResponse(ApiResponse.loading(null));
    try {
      User userData = await _userRepo.fetchDashboard();
      _hasDataChanged = false;
      setApiResponse(ApiResponse.completed(userData));
    } catch (error) {
      setApiResponse(ApiResponse.error(error.toString()));
    }
  }

  Future<String> updateRiceField(RiceField field) async {
    if (field.coordinates == null || field.area == null) {
      return "Koordinat dan luas tidak boleh kosong";
    }
    setApiResponse(ApiResponse.loading(user));
    try {
      String message = await _userRepo.saveRiceField(field.coordinates!, field.area!);
      _hasDataChanged = true;
      if (_response.data != null) {
        setApiResponse(ApiResponse.completed(_response.data?.copyWith(riceField: field)));
      } else {
        setApiResponse(ApiResponse.completed(User(riceField: field)));
      }
      return message;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String> postLogin(String phone) async {
    setApiResponse(ApiResponse.loading(null));
    try {
      String message = await _userRepo.login(phone);
      _hasDataChanged = true;
      setApiResponse(ApiResponse.notStarted());
      return message;
    } catch (error) {
      setApiResponse(ApiResponse.notStarted());
      return Future.error(error.toString());
    }
  }

  Future<String> postRegister(String name, String phone) async {
    setApiResponse(ApiResponse.loading(null));
    try {
      String message = await _userRepo.register(name, phone);
      _hasDataChanged = true;
      setApiResponse(ApiResponse.notStarted());
      return message;
    } catch (error) {
      setApiResponse(ApiResponse.notStarted());
      return Future.error(error.toString());
    }
  }
}
