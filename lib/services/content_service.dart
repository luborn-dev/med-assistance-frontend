import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ContentService {
  final String _baseUrl;
  final String _contentEndpoint;

  ContentService()
      : _baseUrl = dotenv.env["API_BASE_PATH_URL"] ??
            (throw Exception("API_BASE_PATH_URL is not set in .env")),
        _contentEndpoint = dotenv.env["CONTENT_ENDPOINT"] ??
            (throw Exception("CONTENT_ENDPOINT is not set in .env"));

  Future<List<Map<String, dynamic>>> fetchContentsByType(String type) async {
    var url = Uri.parse('$_baseUrl/$_contentEndpoint/$type');
    var response =
        await http.get(url, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .map((item) => {
                'id': item['id'] ?? '',
                'question': item['question'] ?? '',
                'answer': item['answer'] ?? '',
                'content_type': item['content_type'] ?? '',
              })
          .toList();
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Unknown error');
    }
  }
}
