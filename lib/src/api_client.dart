import 'dart:async';
import 'dart:convert';

import 'package:data_model/data_model.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import 'api_request.dart';
import 'request_method.dart';
import 'api_response.dart';

typedef ApiRequest OnBeforeRequest(ApiRequest request);
typedef ApiResponse OnAfterResponse(ApiResponse response);

/// API client
///
/// Implements method `send` to communicate with api-server
class ApiClient {
  final http.Client _httpClient;
  final Uri _apiUri;
  final OnBeforeRequest _onBeforeRequest;
  final OnAfterResponse _onAfterResponse;

  /// Creates new ApiClient
  ///
  /// [apiUri] - API-server uri
  /// [httpClient] - http-клиент:
  ///
  /// * [BrowserClient] - if you use api client in browser
  /// * [IOClient] - if you use api client in Flutter and VM
  ///
  /// [onBeforeRequest] callback, which takes as argument [ApiRequest] and returns [ApiRequest].
  /// This callback is usually used to add somthing to every api request.
  ///
  /// [onAfterResponse] callback, which takes as argument [ApiResponse] and returns [ApiResponse].
  /// This callback is usually used to get some additional info from response data 
  ApiClient(Uri apiUri, http.Client httpClient,
      {OnBeforeRequest onBeforeRequest, OnAfterResponse onAfterResponse})
      : _httpClient = httpClient,
        _apiUri = apiUri,
        _onBeforeRequest = onBeforeRequest,
        _onAfterResponse = onAfterResponse {
    if (apiUri == null) throw (ArgumentError.notNull('apiUri'));
    if (httpClient == null) throw (ArgumentError.notNull('httpClient'));
  }

  /// Sends the request to the API-server.
  Future<ApiResponse> send(ApiRequest request) async {
    if (_onBeforeRequest != null) request = _onBeforeRequest(request);

    var requestUri = _apiUri.replace(
        path: normalize(join(_apiUri.path, request.resourcePath)),
        queryParameters: request.queryParameters);

    ApiResponse restResponse;

    if (request.method == RequestMethod.get) {
      restResponse = await _get(requestUri, request.headers);
    } else if (request.method == RequestMethod.post) {
      restResponse = await _post(requestUri, request.body, request.headers);
    } else if (request.method == RequestMethod.put) {
      restResponse = await _put(requestUri, request.body, request.headers);
    } else if (request.method == RequestMethod.patch) {
      restResponse = await _patch(requestUri, request.body, request.headers);
    } else if (request.method == RequestMethod.delete) {
      restResponse = await _delete(requestUri, request.headers);
    } else {
      throw (ArgumentError(
          'Unsupported RestRequest method: ${request.method}'));
    }

    if (_onAfterResponse != null) restResponse = _onAfterResponse(restResponse);

    return restResponse;
  }

  /// Sends GET-request
  Future<ApiResponse> _get(Uri requestUri,
      [Map<String, String> headers = const {}]) async {
    http.Response response =
        await _httpClient.get(requestUri, headers: headers);
    return ApiResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  /// Sends POST-request
  Future<ApiResponse> _post(Uri requestUri, dynamic body,
      [Map<String, String> headers = const {}]) async {
    final response = await _httpClient.post(requestUri,
        headers: headers, body: json.encode(body, toEncodable: _toEncodable));

    return ApiResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  /// Sends PUT-request.
  Future<ApiResponse> _put(Uri requestUri, dynamic body,
      [Map<String, String> headers = const {}]) async {
    final response = await _httpClient.put(requestUri,
        headers: headers, body: json.encode(body, toEncodable: _toEncodable));

    return ApiResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  /// Sends PATCH-request.
  Future<ApiResponse> _patch(Uri requestUri, dynamic body,
      [Map<String, String> headers = const {}]) async {
    final response = await _httpClient.patch(requestUri,
        headers: headers, body: json.encode(body, toEncodable: _toEncodable));

    return ApiResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  /// Sends DELETE-request.
  Future<ApiResponse> _delete(Uri requestUri,
      [Map<String, String> headers = const {}]) async {
    final response = await _httpClient.delete(requestUri, headers: headers);

    return ApiResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  dynamic _toEncodable(value) {
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    } else if (value is JsonEncodable) {
      return value.json;
    } else {
      throw FormatException('Cannot encode to JSON value: $value');
    }
  }
}
