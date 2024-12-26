part of 'view_model.dart';

class UserViewModel extends ChangeNotifier {
  static final UserViewModel _instance = UserViewModel._internal(UserRepository());
  factory UserViewModel() => _instance;
  UserViewModel._internal(this.userRepo);

  final UserRepository userRepo;
  ApiResponse<User> _response = ApiResponse.notStarted();
  bool _hasDataChanged = true;

  ApiResponse<User> get response => _response;
  bool get hasDataChanged => _hasDataChanged;
  User? get user => _response.data;
  RiceField? get riceField => _response.data?.riceField;

  void setApiResponse(ApiResponse<User> result) {
    _response = result;
    notifyListeners();
  }

  Future<void> getUserData() async {
    if (!_hasDataChanged) return;

    setApiResponse(ApiResponse.loading());
    try {
      User userData = await userRepo.fetchDashboard();
      setApiResponse(ApiResponse.completed(userData));
      _hasDataChanged = false;
    } catch (error) {
      setApiResponse(ApiResponse.error(error.toString()));
    }
  }

  Future<String> updateRiceField(RiceField field) async {
    if (field.coordinates == null || field.area == null) {
      return "Koordinat dan luas tidak boleh kosong";
    }
    try {
      String message = await userRepo.saveRiceField(field.coordinates!, field.area!);
      if (response.data != null) {
        setApiResponse(ApiResponse.completed(_response.data?.copyWith(riceField: field)));
      } else {
        setApiResponse(ApiResponse.completed(User(riceField: field)));
      }
      _hasDataChanged = true;
      return message;
    } catch (error) {
      return error.toString();
    }
  }
}
