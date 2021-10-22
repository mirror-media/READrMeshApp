import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:readr/helpers/apiException.dart';
import 'package:readr/helpers/mNewsCacheManager.dart';

class ApiBaseHelper {
  Future<dynamic> getByUrl(String url,
      {Map<String, String> headers = const {'Cache-control': 'no-cache'},
      bool skipCheck = false}) async {
    Uri uri = Uri.parse(url);
    final response = await http.get(uri, headers: headers);
    var responseJson = returnResponse(response, skipCheck: skipCheck);
    print('Api get done.');
    return responseJson;
  }

  /// Get the json file from cache first.
  /// If there is no json file from cache,
  /// fetch the json file from get api and save the json file to cache.
  Future<dynamic> getByCacheAndAutoCache(
    String url, {
    Duration maxAge = const Duration(days: 30),
    Map<String, String> headers = const {'Cache-control': 'no-cache'},
  }) async {
    MNewsCacheManager mNewsCacheManager = MNewsCacheManager();
    final cacheFile = await mNewsCacheManager.getFileFromCache(url);
    if (cacheFile == null || cacheFile.validTill.isBefore(DateTime.now())) {
      Uri uri = Uri.parse(url);
      final response = await http.get(uri, headers: headers);
      var responseJson = returnResponse(response);

      try {
        // save cache file
        mNewsCacheManager.putFile(url, response.bodyBytes,
            maxAge: maxAge, fileExtension: 'json');
      } catch (e) {
        print('error: $e');
      }

      print('Api get done.');
      return responseJson;
    }

    var file = cacheFile.file;
    if (await file.exists()) {
      var mimeStr = lookupMimeType(file.path);
      String res;
      if (mimeStr == 'application/json') {
        res = await file.readAsString();
      } else {
        res = file.path;
      }

      final response = http.Response(
        res,
        200,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
        },
      );

      return returnResponse(response);
    }
    return returnResponse(http.Response('', 404));
  }

  Future<dynamic> get(String baseUrl, String endpoint) async {
    getByUrl(baseUrl + endpoint);
  }

  Future<dynamic> postByUrl(String url, dynamic body,
      {Map<String, String>? headers}) async {
    Uri uri = Uri.parse(url);
    final response = await http.post(uri, headers: headers, body: body);
    var responseJson = returnResponse(response);
    print('Api post done.');
    return responseJson;
  }

  /// Get the json file from cache first.
  /// If there is no json file from cache,
  /// fetch the json file from get api and save the json file to cache.
  Future<dynamic> postByCacheAndAutoCache(
    String fileKey,
    String url,
    dynamic body, {
    Duration maxAge = const Duration(days: 30),
    Map<String, String> headers = const {'Cache-control': 'no-cache'},
  }) async {
    MNewsCacheManager mNewsCacheManager = MNewsCacheManager();
    final cacheFile = await mNewsCacheManager.getFileFromCache(fileKey);
    if (cacheFile == null || cacheFile.validTill.isBefore(DateTime.now())) {
      Uri uri = Uri.parse(url);
      final response = await http.post(uri, headers: headers, body: body);
      var responseJson = returnResponse(response);

      try {
        // save cache file
        mNewsCacheManager.putFile(fileKey, response.bodyBytes,
            maxAge: maxAge, fileExtension: 'json');
      } catch (e) {
        print('error: $e');
      }

      print('Api post done.');
      return responseJson;
    }

    var file = cacheFile.file;
    if (await file.exists()) {
      var mimeStr = lookupMimeType(file.path);
      String res;
      if (mimeStr == 'application/json') {
        res = await file.readAsString();
      } else {
        res = file.path;
      }

      final response = http.Response(
        res,
        200,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
        },
      );

      return returnResponse(response);
    }
    return returnResponse(http.Response('', 404));
  }

  Future<dynamic> post(String baseUrl, String endpoint, dynamic body) async {
    postByUrl(baseUrl + endpoint, body);
  }

  Future<dynamic> putByUrl(String url, dynamic body) async {
    Uri uri = Uri.parse(url);
    final response = await http.put(uri, body: body);
    var responseJson = returnResponse(response);
    print('Api put done.');
    return responseJson;
  }

  Future<dynamic> put(String baseUrl, String endpoint, dynamic body) async {
    putByUrl(baseUrl + endpoint, body);
  }

  Future<dynamic> deleteByUrl(String url) async {
    Uri uri = Uri.parse(url);
    final response = await http.delete(uri);
    var apiResponse = returnResponse(response);
    print('Api delete done.');
    return apiResponse;
  }

  Future<dynamic> delete(String baseUrl, String endpoint) async {
    deleteByUrl(baseUrl + endpoint);
  }
}

dynamic returnResponse(http.Response response, {bool skipCheck = false}) {
  switch (response.statusCode) {
    case 200:
      String utf8Json = utf8.decode(response.bodyBytes);
      var responseJson = json.decode(utf8Json);

      bool hasData = false;
      // properties responded by member graphql
      if (!skipCheck) {
        hasData = responseJson.containsKey('data') ||
            responseJson.containsKey('items') ||
            // search response
            (responseJson.containsKey('body') &&
                responseJson['body'] != null &&
                responseJson['body'].containsKey('hits')) ||
            // popular json
            responseJson.containsKey('report') ||
            // category json
            responseJson.containsKey('allCategories') ||
            responseJson.containsKey('allPosts') ||
            responseJson.containsKey('allShows');
      }

      if (!hasData && !skipCheck) {
        throw FormatException(response.body.toString());
      }

      return responseJson;
    case 400:
    case 404:
      throw BadRequestException(response.body.toString());
    case 401:
    case 403:
      throw UnauthorisedException(response.body.toString());
    case 500:
    case 502:
      throw InternalServerErrorException(response.body.toString());
    default:
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
  }
}
