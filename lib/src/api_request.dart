import 'request_method.dart';

/// REST API request
class ApiRequest {
  /// Method
  ///
  /// [ApiRequest] supports the following methods:
  /// * GET     get data
  /// * POST    create new resource object
  /// * PUT     replace object data
  /// * PATCH   update object data
  /// * DELETE  delete object
  final RequestMethod method;

  /// Path to the resource
  final String resourcePath;

  Map<String, dynamic> _queryParameters;

  /// Parameters of query
  Map<String, dynamic> get queryParameters => _queryParameters;

  Map<String, String> _headers;

  /// Request headers
  Map<String, String> get headers => _headers;

  /// Request body
  final dynamic body;

  /// Creates new request
  ///
  /// `method` - request method
  ///
  /// `resourcePath` - path to the resource
  ///
  /// `queryParameters` - additional query parameters
  ///
  /// `headers` - request headers
  ///
  /// `body` - request body.
  ///
  /// Request `Content-Type` is always `application/json`. So request body must be encodable by `json.encode()`
  ///
  /// Body can be/can contain:
  ///
  /// * any number type
  /// * [DateTime] objects
  /// * objects implementing [JsonEncodable] interface
  /// * [List] of above mentioned types
  ///
  /// During GET- and DELETE-requests request body is ignored
  ApiRequest(
      {this.method = RequestMethod.get,
      this.resourcePath = '/',
      Map<String, dynamic> queryParameters,
      Map<String, String> headers = const {},
      this.body}) {
    _headers = Map.unmodifiable(headers);
    _queryParameters =
        queryParameters != null ? Map.unmodifiable(queryParameters) : null;
  }

  /// Changes request
  ///
  /// Returns new request with changed data
  ApiRequest change(
          {RequestMethod method,
          String resourcePath,
          Map<String, String> queryParameters,
          Map<String, String> headers,
          dynamic body}) =>
      ApiRequest(
          method: method == null ? this.method : method,
          resourcePath: resourcePath == null ? this.resourcePath : resourcePath,
          queryParameters:
              queryParameters == null ? _queryParameters : queryParameters,
          headers: headers == null ? _headers : headers,
          body: body == null ? this.body : body);
}
