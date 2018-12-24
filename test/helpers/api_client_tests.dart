import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';

import 'package:data_model/data_model.dart';
import 'package:rest_api_client/rest_api_client.dart';

class RestClientTests {
  final Client _httpClient;

  RestClientTests(Client httpClient) : _httpClient = httpClient;

  void run() {
    Uri apiUri;
    ApiClient apiClient;
    final requestParams = {'param1': 'value1', 'param2': 'value2'};

    setUpAll(() async {
      final channel =
          spawnHybridUri('helpers/http_server.dart', stayAlive: true);
      final String hostPort = await channel.stream.first;
      apiUri = Uri.http(hostPort, '/');
      apiClient = ApiClient(apiUri, _httpClient,
          onBeforeRequest: (request) => request.change(
              headers: Map.from(request.headers)
                ..addAll({'X-Requested-With': 'XMLHttpRequest'})),
          onAfterResponse: (response) =>
              response.change(headers: {'X-Added-By-Callback': 'value'}));
    });

    test('get request', () async {
      final response = await apiClient.send(ApiRequest(
          method: RequestMethod.get,
          resourcePath: '/resource',
          queryParameters: requestParams));
      expect(response.statusCode, HttpStatus.ok);
      expect(response.headers['X-Added-By-Callback'], 'value');
      expect(response.body, {
        'method': 'GET',
        'uri': apiUri
            .replace(path: '/resource', queryParameters: requestParams)
            .toString()
      });
    });

    test('post request', () async {
      final response = await apiClient.send(ApiRequest(
          method: RequestMethod.post,
          resourcePath: '/resource',
          body: requestParams));
      expect(response.statusCode, HttpStatus.ok);
      expect(response.headers['X-Added-By-Callback'], 'value');
      expect(response.body, {
        'method': 'POST',
        'uri': apiUri
            .replace(
              path: '/resource',
            )
            .toString(),
        'body': requestParams
      });
    });

    test('put request', () async {
      final response = await apiClient.send(ApiRequest(
          method: RequestMethod.put,
          resourcePath: '/resource',
          body: requestParams));
      expect(response.statusCode, HttpStatus.ok);
      expect(response.headers['X-Added-By-Callback'], 'value');
      expect(response.body, {
        'method': 'PUT',
        'uri': apiUri
            .replace(
              path: '/resource',
            )
            .toString(),
        'body': requestParams
      });
    });

    test('patch request', () async {
      final response = await apiClient.send(ApiRequest(
          method: RequestMethod.patch,
          resourcePath: '/resource',
          body: requestParams));
      expect(response.statusCode, HttpStatus.ok);
      expect(response.headers['X-Added-By-Callback'], 'value');
      expect(response.body, {
        'method': 'PATCH',
        'uri': apiUri
            .replace(
              path: '/resource',
            )
            .toString(),
        'body': requestParams
      });
    });

    test('delete request', () async {
      final response = await apiClient.send(ApiRequest(
          method: RequestMethod.delete,
          resourcePath: '/resource',
          queryParameters: requestParams));
      expect(response.statusCode, HttpStatus.ok);
      expect(response.headers['X-Added-By-Callback'], 'value');
      expect(response.body, {
        'method': 'DELETE',
        'uri': apiUri
            .replace(path: '/resource', queryParameters: requestParams)
            .toString()
      });
    });

    test('get request with unauthorized response', () async {
      final response = await apiClient.send(ApiRequest(
          method: RequestMethod.get,
          resourcePath: '/unauthorized',
          queryParameters: requestParams));
      expect(response.statusCode, HttpStatus.unauthorized);
      expect(response.headers['X-Added-By-Callback'], 'value');
      expect(response.reasonPhrase, '${HttpStatus.unauthorized}-Unauthorized');
    });

    test('get request with internal server error response', () async {
      final response = await apiClient.send(ApiRequest(
          method: RequestMethod.get,
          resourcePath: '/servererror',
          queryParameters: requestParams));
      expect(response.statusCode, HttpStatus.internalServerError);
      expect(response.headers['X-Added-By-Callback'], 'value');
      expect(response.reasonPhrase,
          '${HttpStatus.internalServerError}-Internal Server Error');
    });

    test('post request with unauthorized response', () async {
      final response = await apiClient.send(ApiRequest(
          method: RequestMethod.post,
          resourcePath: '/unauthorized',
          body: requestParams));
      expect(response.statusCode, HttpStatus.unauthorized);
      expect(response.headers['X-Added-By-Callback'], 'value');
      expect(response.reasonPhrase, '${HttpStatus.unauthorized}-Unauthorized');
    });

    test('put request with unauthorized response', () async {
      final response = await apiClient.send(ApiRequest(
          method: RequestMethod.put,
          resourcePath: '/unauthorized',
          body: requestParams));
      expect(response.statusCode, HttpStatus.unauthorized);
      expect(response.headers['X-Added-By-Callback'], 'value');
      expect(response.reasonPhrase, '${HttpStatus.unauthorized}-Unauthorized');
    });

    test('patch request with unauthorized response', () async {
      final response = await apiClient.send(ApiRequest(
          method: RequestMethod.patch,
          resourcePath: '/unauthorized',
          body: requestParams));
      expect(response.statusCode, HttpStatus.unauthorized);
      expect(response.headers['X-Added-By-Callback'], 'value');
      expect(response.reasonPhrase, '${HttpStatus.unauthorized}-Unauthorized');
    });

    test('delete request with unauthorized response', () async {
      final response = await apiClient.send(ApiRequest(
          method: RequestMethod.get,
          resourcePath: '/unauthorized',
          queryParameters: requestParams));
      expect(response.statusCode, HttpStatus.unauthorized);
      expect(response.headers['X-Added-By-Callback'], 'value');
      expect(response.reasonPhrase, '${HttpStatus.unauthorized}-Unauthorized');
    });

    test('toEncodable()', () async {
      final encodable = EncodableObject();
      final response = await apiClient.send(ApiRequest(
          method: RequestMethod.post,
          resourcePath: '/echo-resource',
          body: {'test': encodable}));
      expect(response.statusCode, HttpStatus.ok);
      expect(response.headers['X-Added-By-Callback'], 'value');
      expect(response.body, {
        'test': {
          'id': 1234567890,
          'date': encodable.date.toUtc().toIso8601String()
        }
      });
    });

    test('set null URI throws', () {
      expect(() {
        apiClient.apiUri = null;
      }, throwsArgumentError);
    });
  }
}

class EncodableObjectId extends ObjectId {
  EncodableObjectId._(id) : super(id);
  factory EncodableObjectId(id) {
    if (id == null) return null;
    return EncodableObjectId._(id);
  }
}

class EncodableObject implements JsonEncodable {
  final id = EncodableObjectId(1234567890);
  final date = DateTime.now();
  Map<String, dynamic> get json => {'id': id, 'date': date};
}
