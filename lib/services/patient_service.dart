import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PatientService {
  final String _baseUrl;
  final String _patientsEndpoint;
  final String _findCepEndpoint;

  PatientService()
      : _baseUrl = dotenv.env['API_BASE_PATH_URL'] ??
            (throw Exception("API_BASE_PATH_URL is not set in .env")),
        _patientsEndpoint = dotenv.env['PATIENTS_ENDPOINT'] ??
            (throw Exception("PATIENTS_ENDPOINT is not set in .env")),
        _findCepEndpoint = dotenv.env['FIND_CEP_ENDPOINT'] ??
            (throw Exception("FIND_CEP_ENDPOINT is not set in .env"));

  Future<Map<String, dynamic>> fetchAddressByZipCode(String zipCode) async {
    try {
      final response =
          await http.get(Uri.parse('$_findCepEndpoint/$zipCode/json/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['erro'] == null) {
          return {
            'street': data['logradouro'] ?? '',
            'city': data['localidade'] ?? '',
            'state': data['uf'] ?? ''
          };
        } else {
          throw Exception("CEP não encontrado");
        }
      } else {
        throw Exception("Erro ao buscar o CEP");
      }
    } catch (e) {
      throw Exception("Erro ao buscar o CEP: $e");
    }
  }

  Future<void> registerPatient(
      Map<String, dynamic> patientData, BuildContext context) async {
    final url = Uri.parse('$_baseUrl/$_patientsEndpoint');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(patientData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paciente registrado com sucesso!")),
        );
      } else {
        final error = jsonDecode(response.body)['detail'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $error")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao registrar paciente: $e")),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getPatientsByDoctorId(
      String doctorId) async {
    final url = Uri.parse('$_baseUrl/$_patientsEndpoint?doctor_id=$doctorId');

    var response =
        await http.get(url, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao carregar pacientes: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getPatients() async {
    final url = Uri.parse('$_baseUrl/$_patientsEndpoint');

    var response =
        await http.get(url, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao carregar pacientes: ${response.body}');
    }
  }
}
