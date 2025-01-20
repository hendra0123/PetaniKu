abstract class BaseApiServices {
  Future<dynamic> getJSONRequest(String endpoint);
  Future<dynamic> postJSONRequest(String endpoint, dynamic data);
  Future<dynamic> putJSONRequest(String endpoint, dynamic data);
  Future<dynamic> deleteJSONRequest(String endpoint);
  Future<dynamic> postMultipartRequest(String endpoint,
      Map<String, String> fields, List<Map<String, dynamic>> files);
}
