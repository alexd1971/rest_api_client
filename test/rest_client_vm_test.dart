@Timeout(const Duration(seconds: 10))
@TestOn('vm')

import 'package:test/test.dart';
import 'package:http/io_client.dart';

import 'helpers/api_client_tests.dart';

void main() {
  RestClientTests(IOClient()).run();
}
