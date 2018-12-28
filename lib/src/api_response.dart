/// Api-server response
class ApiResponse {
  /// Http-status code
  final int statusCode;

  Map<String, String> _headers;

  /// Response headers
  Map<String, String> get headers => _headers;

  /// Message from server
  final String reasonPhrase;

  /// Response body
  final body;

  ApiResponse(
      {this.statusCode,
      this.reasonPhrase,
      Map<String, String> headers,
      this.body}) {
    _headers = Map.unmodifiable(headers);
  }

  /// Changes response
  ///
  /// Returns new [ApiResponse] with changed paraameters
  /// If nothing to change returns a copy of the response
  ApiResponse change(
          {int statusCode,
          String reasonPhrase,
          Map<String, String> headers,
          body}) =>
      ApiResponse(
          statusCode: statusCode == null ? this.statusCode : statusCode,
          reasonPhrase: reasonPhrase == null ? this.reasonPhrase : reasonPhrase,
          headers: headers == null ? this.headers : headers,
          body: body == null ? this.body : body);
}
