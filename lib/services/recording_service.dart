import 'package:http/http.dart' as http;
import 'dart:convert';

class RecordingService {
  static const String baseUrl = 'http://172.20.10.3:8000/api/procedures';
  static const String patientsBaseUrl = 'http://172.20.10.3:8000/api/patients';
  static const String doctorsBaseUrl = 'http://172.20.10.3:8000/api/doctors';

  static Future<List<dynamic>> fetchRecordings(String doctorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl?doctor_id=$doctorId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      List<dynamic> recordings = json.decode(utf8.decode(response.bodyBytes));

      // Agora buscamos os detalhes dos pacientes e médicos usando o ID
      for (var recording in recordings) {
        // Busca detalhes do paciente pelo ID do paciente
        final patientId = recording[
            'patient_id']; // Certifique-se que o 'patient_id' é parte do objeto recording
        final patientResponse = await http.get(
          Uri.parse('$patientsBaseUrl/$patientId'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        );

        if (patientResponse.statusCode == 200) {
          var patientData = json.decode(utf8.decode(patientResponse.bodyBytes));
          recording['patient_birthdate'] = patientData['birthdate'];
          recording['patient_address'] = patientData['address'];
          recording['patient_cpf'] = patientData['cpf'];
          recording['patient_phone'] = patientData['phone'];
        }

        // Busca detalhes do médico pelo ID
        final doctorResponse = await http.get(
          Uri.parse('$doctorsBaseUrl/${recording['doctorId']}'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        );

        if (doctorResponse.statusCode == 200) {
          var doctorData = json.decode(utf8.decode(doctorResponse.bodyBytes));
          recording['doctor_name'] = doctorData['username'];
          recording['doctor_email'] = doctorData['email'];
          recording['doctor_affiliation'] = doctorData['affiliation'];
        }
      }

      return recordings;
    } else if (response.statusCode == 404) {
      return [];
    } else if (response.statusCode == 401) {
      throw Exception('Não autorizado. Por favor, faça login novamente.');
    } else {
      throw Exception(
          'Erro ao carregar gravações: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  static Future<void> deleteRecording(String recordingId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$recordingId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Procedimento não encontrado.');
    } else if (response.statusCode == 401) {
      throw Exception('Não autorizado a deletar este procedimento.');
    } else {
      throw Exception(
          'Falha ao deletar gravação: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }
}
