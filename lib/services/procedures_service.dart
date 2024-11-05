import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';

class ProcedureService {
  final String _baseUrl;
  final String _proceduresEndpoint;

  ProcedureService()
      : _baseUrl = dotenv.env['API_BASE_PATH_URL'] ??
            (throw Exception("API_BASE_PATH_URL is not set in .env")),
        _proceduresEndpoint = dotenv.env['PROCEDURES_ENDPOINT'] ??
            (throw Exception("PROCEDURES_ENDPOINT is not set in .env"));

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
}
