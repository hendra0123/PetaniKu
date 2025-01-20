import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:petaniku/data/app_exception.dart';
import 'package:petaniku/data/network/base_api_services.dart';
import 'package:petaniku/shared/shared.dart';
import 'package:http_parser/http_parser.dart';

class NetworkApiServices implements BaseApiServices {
  @override
  Future getJSONRequest(String endpoint) async {
    dynamic responseJson;
    try {
      final response = await http.get(Uri.parse(AppConstant.baseUrl + endpoint),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': "Bearer ${AppConstant.authentication}",
          });
      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException('Pastikan anda terhubung ke internet');
    } on TimeoutException {
      throw FetchDataException('Server tidak merespon');
    }
    return responseJson;
  }

  @override
  Future postJSONRequest(String endpoint, data) async {
    dynamic responseJson;
    try {
      final response = await http.post(
        Uri.parse(AppConstant.baseUrl + endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': "Bearer ${AppConstant.authentication}",
        },
        body: jsonEncode(data),
      );
      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException('Pastikan anda terhubung ke internet');
    } on TimeoutException {
      throw FetchDataException('Server tidak merespon');
    }
    return responseJson;
  }

  @override
  Future putJSONRequest(String endpoint, data) async {
    dynamic responseJson;
    try {
      final response = await http.put(
        Uri.parse(AppConstant.baseUrl + endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': "Bearer ${AppConstant.authentication}",
        },
        body: data != null ? jsonEncode(data) : null,
      );
      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException('Pastikan anda terhubung ke internet');
    } on TimeoutException {
      throw FetchDataException('Server tidak merespon');
    }
    return responseJson;
  }

  @override
  Future deleteJSONRequest(String endpoint) async {
    dynamic responseJson;
    try {
      final response = await http.delete(
          Uri.parse(AppConstant.baseUrl + endpoint),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': "Bearer ${AppConstant.authentication}",
          });
      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException('Pastikan anda terhubung ke internet');
    } on TimeoutException {
      throw FetchDataException('Server tidak merespon');
    }
    return responseJson;
  }

  @override
  Future<dynamic> postMultipartRequest(String endpoint,
      Map<String, dynamic> payload, List<Map<String, dynamic>> files) async {
    dynamic responseJson;
    try {
      final request = http.MultipartRequest(
          "POST", Uri.parse(AppConstant.baseUrl + endpoint));
      request.headers
          .addAll({'Authorization': "Bearer ${AppConstant.authentication}"});
      request.fields['payload'] = jsonEncode(payload);
      for (var fileData in files) {
        final file = await http.MultipartFile.fromPath(
          fileData['key'],
          fileData['path'],
          contentType: MediaType(fileData['mimeType'], fileData['subtype']),
        );
        request.files.add(file);
      }
      final response = await request.send();
      final responseString = await http.Response.fromStream(response);
      responseJson = returnResponse(responseString);
    } on SocketException {
      throw NoInternetException('Pastikan anda terhubung ke internet');
    } on TimeoutException {
      throw FetchDataException('Server tidak merespon');
    }
    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    dynamic responseJson = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        return responseJson;
      case 400:
        throw BadRequestException(responseJson['pesan']);
      case 401:
        throw UnauthorizedException(responseJson['pesan']);
      case 404:
        throw NotFoundException(responseJson['pesan']);
      case 500:
      default:
        throw FetchDataException(
            'Terjadi kesalahan saat berkomunikasi dengan server');
    }
  }
}
