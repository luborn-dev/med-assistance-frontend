import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:med_assistance_frontend/screens/recording_screen.dart';
import 'package:med_assistance_frontend/widget/gradient_container.dart';
import 'package:med_assistance_frontend/utils/procedure_options.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreRecordingScreen extends StatefulWidget {
  const PreRecordingScreen({Key? key}) : super(key: key);

  @override
  _PreRecordingScreenState createState() => _PreRecordingScreenState();
}

class _PreRecordingScreenState extends State<PreRecordingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedProcedureType;
  String? _selectedExactProcedureName;
  List<String> _filteredProcedureOptions = [];
  List<Map<String, dynamic>> _patients = [];

  bool _isPatientListEmpty = false; // Flag para indicar se lista de pacientes está vazia
  bool _isLoading = true; // Flag para indicar se está carregando os dados

  final Map<String, List<String>> _procedureOptions = {
    'Cirurgias': List.from(cirurgias)..sort(),
    'Consulta': List.from(consultas)..sort(),
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProcedureOptions);
    _loadPatients();
  }

  @override
  void dispose() {
    _patientController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? doctorId = prefs.getString('doctorId');
    print(doctorId);

    if (doctorId != null) {
      var url = Uri.parse('http://172.20.10.3:8000/api/patients?doctor_id=$doctorId');
      var response = await http.get(url, headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        setState(() {
          _patients = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          _isPatientListEmpty = _patients.isEmpty; // Verifica se a lista está vazia
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar pacientes: ${response.body}')),
        );
      }
    }

    setState(() {
      _isLoading = false; // Desativa o estado de carregamento após completar o fetch
    });
  }

  void _navigateToRecordingScreen(Map<String, dynamic> procedureData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordingScreen(procedureData: procedureData),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _filteredProcedureOptions.contains(_selectedExactProcedureName)) {
      var procedureData = {
        'procedure_type': _selectedProcedureType,
        'patient_name': _patientController.text,
        'exact_procedure_name': _selectedExactProcedureName,
      };

      _navigateToRecordingScreen(procedureData);
    }
  }

  void _filterProcedureOptions() {
    if (_selectedProcedureType != null) {
      setState(() {
        _filteredProcedureOptions = _procedureOptions[_selectedProcedureType]!
            .where((option) => option.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      });
    }
  }

  void _navigateToPatientRegistration() {
    Navigator.pushNamed(context, '/patientregistration');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: Stack(
          children: [
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator() // Exibe indicador de carregamento enquanto os dados estão sendo buscados
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (_isPatientListEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Nenhum paciente encontrado. Cadastre um paciente antes de continuar.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _navigateToPatientRegistration,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              child: const Text(
                                'Cadastrar Paciente',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (!_isPatientListEmpty) ...[
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildProcedureTypeDropdown(),
                            const SizedBox(height: 20),
                            _buildPatientField(),
                            const SizedBox(height: 20),
                            _buildProcedureNameField(),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_filteredProcedureOptions.contains(_selectedExactProcedureName)) {
                                    _submitForm();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Por favor, preencha corretamente o nome do procedimento.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 32.0),
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                                child: const Text(
                                  'Continuar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              top: 32,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, "/main");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcedureTypeDropdown() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tipo de Procedimento",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: _selectedProcedureType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            dropdownColor: Colors.white,
            items: _procedureOptions.keys
                .map((label) => DropdownMenuItem(
              value: label,
              child: Text(label),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedProcedureType = value;
                _selectedExactProcedureName = null;
                _filteredProcedureOptions = _procedureOptions[value] ?? [];
                _filterProcedureOptions();
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione o tipo de procedimento';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatientField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Paciente",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          TypeAheadFormField<Map<String, dynamic>>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _patientController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Digite para buscar...',
              ),
            ),
            suggestionsCallback: (pattern) {
              return _patients.where((patient) =>
                  patient['name'].toLowerCase().contains(pattern.toLowerCase()));
            },
            itemBuilder: (context, Map<String, dynamic> suggestion) {
              return ListTile(
                title: Text(suggestion['name']),
                subtitle: Text(suggestion['cpf']),
              );
            },
            onSuggestionSelected: (suggestion) {
              setState(() {
                _patientController.text = suggestion['name'];
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione um paciente';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProcedureNameField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Procedimento",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          TypeAheadFormField<String>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Digite para buscar...',
              ),
            ),
            errorBuilder: (context, error) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Ocorreu um erro: $error',
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
            loadingBuilder: (context) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              );
            },
            noItemsFoundBuilder: (context) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Nenhum procedimento encontrado',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            suggestionsCallback: (pattern) {
              return _filteredProcedureOptions.where((option) =>
                  option.toLowerCase().contains(pattern.toLowerCase()));
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (suggestion) {
              setState(() {
                _searchController.text = suggestion;
                _selectedExactProcedureName = suggestion;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione o nome exato do procedimento';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
