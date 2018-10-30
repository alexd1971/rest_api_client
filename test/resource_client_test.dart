@TestOn('vm')
import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:http/io_client.dart';

import 'package:data_model/data_model.dart';
import 'package:rest_api_client/rest_api_client.dart';

class TestResource extends ResourceClient<TestResourceObject> {
  TestResource({@required ApiClient apiClient})
      : super('echo-resource', apiClient);

  TestResourceObject createObject(Map<String, dynamic> json) =>
      TestResourceObject.fromJson(json);
}

class TestResourceObject extends Model {
  Map<String, dynamic> _data;

  TestResourceObject.fromJson(Map<String, dynamic> json) : _data = json;

  @override
  Map<String, dynamic> get json => _data;
}

class TestResourceObjectId extends ObjectId {
  TestResourceObjectId(id) : super(id);
}

void main() {
  TestResource testResource;
  final newObject = TestResourceObject.fromJson({'test': 'create object'});

  setUpAll(() async {
    final channel = spawnHybridUri('helpers/http_server.dart', stayAlive: true);
    final String hostPort = await channel.stream.first;
    final apiUri = Uri.http(hostPort, '/');
    final apiClient = ApiClient(apiUri, IOClient(),
        onBeforeRequest: (request) => request.change(
            headers: Map.from(request.headers)
              ..addAll({'X-Requested-With': 'XMLHttpRequest'})));
    testResource = TestResource(apiClient: apiClient);
  });

  test('create object', () async {
    final created = await testResource.create(newObject);
    expect(created.json, newObject.json);
  });

  test('update object', () async {
    final updated = await testResource.update(newObject);
    expect(updated.json, newObject.json);
  });

  test('replace object', () async {
    final replaced = await testResource.replace(newObject);
    expect(replaced.json, newObject.json);
  });

  test('get object', () async {
    final object = await testResource.read(TestResourceObjectId(1));
    expect(object.json,
        TestResourceObject.fromJson({'id': 1}).json);
  });

  test('get objects by query', () async {
    final objects = await testResource.read({'all': 'true'});
    expect(
        objects.map((object) => object.json).toList(),
        containsAll([
          TestResourceObject.fromJson({'id': 1}).json,
          TestResourceObject.fromJson({'id': 2}).json
        ]));
  });

  test('delete object', () async {
    final deleted = await testResource.delete(TestResourceObjectId(1));
    expect(deleted.json, TestResourceObject.fromJson({'id': 1}).json);
  });

  test('delete objects by query', () async {
    final deleted = await testResource.delete({'all': 'true'});
    expect(
        deleted.map((object) => object.json).toList(),
        containsAll([
          TestResourceObject.fromJson({'id': 1}).json,
          TestResourceObject.fromJson({'id': 2}).json
        ]));
  });
}
