import 'dart:async';
import 'dart:io';

import 'package:http/browser_client.dart';

import 'package:data_model/data_model.dart';
import 'package:rest_api_client/rest_api_client.dart';

/// User identifier
class UserId extends ObjectId {
  UserId(id) : super(id);
}

/// User
class User extends Model {
  /// Username
  String userName;

  /// Last name
  String lastName;

  /// First name
  String firstName;

  /// Full name
  String get fullName => '$firstName $lastName';

  /// Date of birth
  DateTime birthDate;

  /// Creates user
  User({UserId id, this.userName, this.lastName, this.firstName, this.birthDate}): super(id);

  /// Creates user from JSON-data
  User.fromJson(Map<String, dynamic> json)
      : userName = json['username'],
        lastName = json['lastname'],
        firstName = json['firstname'],
        birthDate = DateTime.parse(json['birth_date']),
        super(json['id']);

  @override
  Map<String, dynamic> get json => super.json..addAll({
      'username': userName,
      'lastname': lastName,
      'firstname': firstName,
      'birth_date': birthDate
    })..removeWhere((key, value) => value == null);
}

/// Users resource client
///
/// Operates with [User]-objects.
/// 
/// Implements methods:
/// * `login` - enter into system
/// * `logout` - exit from system
class Users extends ResourceClient<User> {
  Users(ApiClient apiClient)
      : super('/users', apiClient);

  User createObject(Map<String, dynamic> json) => User.fromJson(json);

  Future<User> login(String username, String password) async {
    final response = await apiClient.send(ApiRequest(
        method: RequestMethod.post,
        resourcePath: '$resourcePath/login',
        body: {'username': username, 'password': password}));
    if (response.statusCode != HttpStatus.ok) {
      throw (response.reasonPhrase);
    }
    return User.fromJson(response.body);
  }

  Future logout() async {
    final response = await apiClient.send(ApiRequest(
        method: RequestMethod.post, resourcePath: '$resourcePath/logout'));
    if (response.statusCode != HttpStatus.ok) {
      throw (response.reasonPhrase);
    }
  }
}

main() async {
  final apiClient = ApiClient(Uri.http('api.examle.com', '/'), BrowserClient(),
      onBeforeRequest: (request) => request.change(
          headers: Map.from(request.headers)
            ..addAll({'X-Requested-With': 'XMLHttpRequest'})),
      onAfterResponse: (response) {
        saveToken(response.headers[HttpHeaders.authorizationHeader]);
        return response;
      });

  final users = Users(apiClient);

  User currentUser;
  try {
    currentUser = await users.login('username', 'password');
  } catch (e) {
    // Here bad failed login should be processed. The reason is in e.message.
  }
  print('Пользователь ${currentUser.fullName} успешно аутентифицировался');

  final newUser = User(
      userName: 'newuser',
      firstName: 'Bob',
      lastName: 'Martin',
      birthDate: DateTime(1952));

  User createdUser;
  try {
    createdUser = await users.create(newUser);
  } catch (e) {
    // Handle create user exception
  }

  print('Пользователь ${createdUser.fullName} успешно создан');

  List<User> bobs;
  try {
    bobs = await users.read({'firstname': 'Bob'});
  } catch (e) {
    // Handle get data exception
  }
  bobs.forEach((bob) {
    // Do somethin with users having name Bob
    print('${bob.fullName} - ${bob.birthDate}');
  });
}

saveToken(String tiken) {
  // Save JWT
}
