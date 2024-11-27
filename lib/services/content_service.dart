import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> cacheData(String key, dynamic data) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(key, jsonEncode(data));
}

Future<dynamic> getCachedData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedData = prefs.getString(key);
  return cachedData != null ? jsonDecode(cachedData) : null;
}

Future<List<dynamic>> fetchAndCacheContent(String contentType) async {
  final String baseUrl = dotenv.env["API_BASE_PATH_URL"] ??
      (throw Exception("API_BASE_PATH_URL is not set in .env"));
  final String contentEndpoint = dotenv.env["CONTENT_ENDPOINT"] ??
      (throw Exception("CONTENT_ENDPOINT is not set in .env"));

  final cachedData = await getCachedData(contentType);

  if (cachedData != null) {
    return cachedData;
  }

  final response = await http.get(
      Uri.parse('$baseUrl/$contentEndpoint/$contentType'),
      headers: {"Content-Type": "application/json"});

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final content = data["content"];
    await cacheData(contentType, content);
    return content;
  } else {
    throw Exception('Failed to load $contentType');
  }
}
