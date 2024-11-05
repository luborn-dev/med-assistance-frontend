import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  final String _baseUrl;
  final String _usersEndpoint;

  UserService()
      : _baseUrl = dotenv.env['API_BASE_PATH_URL'] ??
            (throw Exception("API_BASE_PATH_URL is not set in .env")),
        _usersEndpoint = dotenv.env['USERS_ENDPOINT'] ??
            (throw Exception("USERS_ENDPOINT is not set in .env"));

  Future<void> register(
      String name, String email, String password, String professionalId) async {
    var url = Uri.parse('$_baseUrl/$_usersEndpoint');

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'professional_id': professionalId,
      }),
    );

    if (response.statusCode != 200) {
      var error = jsonDecode(response.body)['detail'];
      throw Exception(error ?? 'Unknown error while trying to register');
    }
  }

  Future<void> updateUser(
      String userId, String name, String email, String professionalId) async {
    var url = Uri.parse('$_baseUrl/$_usersEndpoint/$userId');

    var response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': name,
        'email': email,
        'professional_id': professionalId,
      }),
    );

    if (response.statusCode != 200) {
      var error = jsonDecode(response.body)['detail'];
      throw Exception(
          error ?? 'Unknown error while trying to update user data');
    }
  }

  Future<void> deleteUser(String userId) async {
    var url = Uri.parse('$_baseUrl/$_usersEndpoint/$userId');

    var response = await http.delete(url);

    if (response.statusCode != 200) {
      var error = jsonDecode(response.body)['detail'];
      throw Exception(error ?? 'Unknown error while trying to delete user');
    }
  }
}
