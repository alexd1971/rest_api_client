class RequestMethod {
  static const RequestMethod get = RequestMethod._('GET');
  static const RequestMethod post = RequestMethod._('POST');
  static const RequestMethod put = RequestMethod._('PUT');
  static const RequestMethod patch = RequestMethod._('PATCH');
  static const RequestMethod delete = RequestMethod._('DELETE');

  final String _method;

  const RequestMethod._(String method) : _method = method;

  @override
  String toString() => _method;

  @override
  bool operator ==(other) {
    if (other is RequestMethod) return _method == other._method;
    return false;
  }

  @override
  int get hashCode => _method.hashCode;
}
