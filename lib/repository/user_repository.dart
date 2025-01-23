part of 'repository.dart';

class UserRepository {
  final String prefixEndpoint = "/user";

  Future<String> login(String phone) async {
    final user = User(phone: phone);
    try {
      dynamic response = await apiServices.postJSONRequest("$prefixEndpoint/login", user.toJson());
      AppConstant.authentication = response["token"];
      return response["pesan"].toString();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> register(String name, String phone) async {
    final user = User(name: name, phone: phone);
    try {
      dynamic response = await apiServices.postJSONRequest(prefixEndpoint, user.toJson());
      AppConstant.authentication = response["token"];
      return response["pesan"].toString();
    } catch (e) {
      rethrow;
    }
  }

  Future<User> fetchDashboard() async {
    try {
      dynamic response = await apiServices.getJSONRequest(prefixEndpoint);
      return User.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> saveRiceField(List<LatLng> coordinates, num area) async {
    final payload = {
      "area": area,
      "polygon": coordinates.map((coordinate) {
        return [coordinate.latitude, coordinate.longitude];
      }).toList(),
    };
    try {
      dynamic response = await apiServices.putJSONRequest(prefixEndpoint, payload);
      return response["pesan"].toString();
    } catch (e) {
      rethrow;
    }
  }
}
