import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class RecordingService {
  final String _baseUrl;
  final String _proceduresEndpoint;

  RecordingService()
      : _baseUrl = dotenv.env['API_BASE_PATH_URL'] ??
            (throw Exception("API_BASE_PATH_URL is not set in .env")),
        _proceduresEndpoint = dotenv.env['PROCEDURES_ENDPOINT'] ??
            (throw Exception("PROCEDURES_ENDPOINT is not set in .env"));

  Future<List<dynamic>> fetchRecordings() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$_proceduresEndpoint'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      List<dynamic> recordings = jsonDecode(utf8.decode(response.bodyBytes));

      // Converter strings de data para DateTime
      recordings = recordings.map((recording) {
        recording['data_gravacao'] = recording['data_gravacao'] != null
            ? DateTime.parse(recording['data_gravacao'] as String)
            : null;
        return recording;
      }).toList();

      return recordings;
    } else {
      throw Exception('Erro ao carregar gravações');
    }
  }

  Future<void> deleteRecording(String procedureId, String recordingId) async {
    final response = await http.delete(
      Uri.parse(
          '$_baseUrl/$_proceduresEndpoint/$procedureId/recordings/$recordingId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Gravação não encontrada.');
    } else {
      throw Exception(
          'Falha ao deletar gravação: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  Future<void> sendRecording({
    required Map<String, dynamic> procedureData,
    required File recordingFile,
    required BuildContext context,
  }) async {
    final apiUrl = '$_baseUrl/$_proceduresEndpoint/upload';

    if (!await recordingFile.exists()) {
      throw Exception("Arquivo de gravação não encontrado.");
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields['paciente_id'] = procedureData['paciente_id'];
      request.fields['medico_id'] = procedureData['medico_id'];
      request.fields['tipo'] = procedureData['tipo'];
      request.fields['procedimento'] = procedureData['procedimento'];
      request.fields['transcricao'] = '';
      request.fields['sumarizacao'] = '';

      request.files.add(await http.MultipartFile.fromPath(
        'arquivo_audio',
        recordingFile.path,
        contentType: MediaType('audio', 'm4a'),
      ));

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gravação enviada com sucesso.")),
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        final error = jsonDecode(responseBody)['detail'] ?? 'Erro desconhecido';
        throw Exception('Erro ao enviar a gravação: $error');
      }
    } catch (e) {
      throw Exception('Erro ao enviar a gravação: $e');
    }
  }

  Future<void> generateMedicalHistory(
      {required String patientId,
      required List<dynamic> transcriptions}) async {}
}
