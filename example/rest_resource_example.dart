import 'dart:async';
import 'dart:io';

import 'package:http/browser_client.dart';

import 'package:data_model/data_model.dart';
import 'package:rest_api_client/rest_api_client.dart';

/// Идентификатор пользователя
class UserId extends ObjectId {
  UserId(id) : super(id);
}

/// Пользователь
class User extends Model {
  /// Имя пользователя
  String userName;

  /// Фамилия
  String lastName;

  /// Имя
  String firstName;

  /// Полное имя
  String get fullName => '$firstName $lastName';

  /// Дата рождения
  DateTime birthDate;

  /// Создает пользователя
  User({UserId id, this.userName, this.lastName, this.firstName, this.birthDate}): super(id);

  /// Создает пользователя из JSON-данных
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

/// Ресурс Users
///
/// Оперирует с объектами [User].
/// В дополнение к стандартным CRUD-методам реализует методы:
/// * `login` - вход в систему
/// * `logout` - выход из системы
class Users extends ResourceClient<User> {
  Users(ApiClient apiClient)
      : super('/users', apiClient);

  User createObject(Map<String, dynamic> json) => User.fromJson(json);

  /// Осуществляет вход в систему
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

  /// Осуществляет выход из системы
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
    // Здесь обрабатываем неудачный логин. Причина в e.message.
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
    // Обработка ошибки создания пользователя
  }

  print('Пользователь ${createdUser.fullName} успешно создан');

  List<User> bobs;
  try {
    bobs = await users.read({'firstname': 'Bob'});
  } catch (e) {
    // Обработка ошибки получения данных
  }
  bobs.forEach((bob) {
    // Выполняем что-то для пользователей с именем Bob
    print('${bob.fullName} - ${bob.birthDate}');
  });
}

saveToken(String tiken) {
  // Сохранение jwt-токена
}
