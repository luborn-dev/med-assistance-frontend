import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginService {
  final String _baseUrl;
  final String _loginEndpoint;

  LoginService()
      : _baseUrl = dotenv.env["API_BASE_PATH_URL"] ??
            (throw Exception("API_BASE_PATH_URL is not set in .env")),
        _loginEndpoint = dotenv.env["LOGIN_ENDPOINT"] ??
            (throw Exception("LOGIN_ENDPOINT is not set in .env"));

  Future<Map<String, dynamic>> login(String email, String password) async {
    var url = Uri.parse('$_baseUrl/$_loginEndpoint');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      var userData = jsonDecode(response.body);
      await _saveUserData(userData);
      return userData;
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Unknown error');
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', userData['email']);
    await prefs.setString('name', userData['name']);
    await prefs.setString('professionalId', userData['professional_id']);
    await prefs.setString('doctorId', userData['id']);
  }
}
