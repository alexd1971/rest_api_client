import 'dart:async';
import 'dart:io';

import 'package:data_model/data_model.dart';
import 'package:meta/meta.dart';

import 'api_request.dart';
import 'api_response.dart';
import 'request_method.dart';
import 'api_client.dart';

/// Resource client base class
///
/// Implements all CRUD-methods:
/// * `create` - creates new object
/// * `read` - read data from resource
/// * `update` - update object data with supplied atributes
/// * `replace` - replace object data with supplied data
/// * `delete` - deletes object from resource
///
/// `T` - type of objects which the resource stores
abstract class ResourceClient<T extends Model> {
  /// Resource path
  final String resourcePath;

  /// Api-client
  @protected
  final ApiClient apiClient;

  /// Creates new resource
  /// 
  /// [resourcePath] путь к ресурсу на API-сервере.
  /// 
  /// If path contains leading slash (`/resource`) it will be interpreted as absolute path
  /// from root of server. In this case the path set in [apiClient] will be overridden.
  /// 
  /// If path is without leading slash `resource`, then this path will be added to the path
  /// set in [apiClient].
  ResourceClient(this.resourcePath, this.apiClient) {
    if (resourcePath == null) throw (ArgumentError.notNull('resourcePath'));
    if (apiClient == null) throw (ArgumentError.notNull('apiClient'));
  }

  /// Creates new object of resource
  Future<T> create(T obj, {Map<String, String> headers = const {}}) async {
    if (!(obj is JsonEncodable))
      throw ArgumentError.value(
          obj, 'obj', 'Creating object must be JsonEncodable');
    final response = await apiClient.send(ApiRequest(
        method: RequestMethod.post,
        resourcePath: resourcePath,
        headers: headers,
        body: obj.json));
    return processResponse(response);
  }

  /// Reads resource data
  ///
  /// `obj` can be:
  ///
  /// * object identifier (inherits [ObjectId])
  /// * [Map] with query parameters
  ///
  /// If `obj` is identifier then method returns [Future] which resolves into object of type `T`
  ///
  /// If `obj` is an object with query parameters, then method returns [Future] which resolves
  /// into [Lsit]<T>
  Future read(dynamic obj, {Map<String, String> headers = const {}}) async {
    String path;
    Map<String, dynamic> queryParameters;

    if (obj is ObjectId) {
      path = '$resourcePath/$obj';
    } else if (obj is Map) {
      path = resourcePath;
      queryParameters = Map<String, dynamic>.from(obj);
    } else {
      throw (ArgumentError.value(obj, 'obj',
          'Read criteria must be an ObjectId or Map of query parameters'));
    }
    final response = await apiClient.send(ApiRequest(
        method: RequestMethod.get,
        resourcePath: path,
        queryParameters: queryParameters,
        headers: headers));
    return processResponse(response);
  }

  /// Updates object attributes
  ///
  /// Only non `null` attributes are updated. All attributes having `null`-value are ignored
  ///
  /// Returns [Future] which resolves into updated object
  Future<T> update(T obj, {Map<String, String> headers = const {}}) async {
    if (!(obj is JsonEncodable))
      throw ArgumentError.value(
          obj, 'obj', 'Updating object must be JsonEncodable');
    final response = await apiClient.send(ApiRequest(
        method: RequestMethod.patch,
        resourcePath: resourcePath,
        headers: headers,
        body: obj.json));
    return processResponse(response);
  }

  /// Replaces object data with supplied object
  ///
  /// If some attributes have value `null` they will be removed from object
  ///
  /// Returns [Future] which resolves into replaced object
  Future<T> replace(T obj, {Map<String, String> headers = const {}}) async {
    if (!(obj is JsonEncodable))
      throw ArgumentError.value(
          obj, 'obj', 'Replacing object must be JsonEncodable');
    final response = await apiClient.send(ApiRequest(
        method: RequestMethod.put,
        resourcePath: resourcePath,
        headers: headers,
        body: obj.json));
    return processResponse(response);
  }

  /// Deletes object from resource
  ///
  /// `obj` can be:
  ///
  /// * object identifier (inherits [ObjectId])
  /// * [Map] with query parameters
  ///
  /// If `obj` is identifier then method deletes the object with this identifier  and returns [Future]
  /// which resolves into object of type `T`
  ///
  /// If `obj` is an object with query parameters, then method returns [Future] which resolves
  /// into [Lsit]<T>
  Future delete(dynamic obj, {Map<String, String> headers = const {}}) async {
    String path;
    Map<String, dynamic> queryParameters;

    if (obj is ObjectId) {
      path = '$resourcePath/$obj';
    } else if (obj is Map) {
      path = resourcePath;
      queryParameters = Map<String, dynamic>.from(obj);
    } else {
      throw (ArgumentError.value(obj, 'obj',
          'Delete criteria must be an ObjectId or Map of query parameters'));
    }
    final response = await apiClient.send(ApiRequest(
        method: RequestMethod.delete,
        resourcePath: path,
        queryParameters: queryParameters,
        headers: headers));
    return processResponse(response);
  }

  @protected
  dynamic processResponse(ApiResponse response) {
    if (response.statusCode != HttpStatus.ok) {
      throw (HttpException('${response.reasonPhrase}\n${response.body}'));
    }
    if (response.body is Map) {
      return createObject(response.body);
    } else if (response.body is List) {
      return List<T>.from(response.body.map((json) => createObject(json)));
    } else {
      throw FormatException('Invalid http response format');
    }
  }

  /// Creates object of type `T`
  @protected
  T createObject(Map<String, dynamic> json);
}
