import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:med_assistance_frontend/components/background_container.dart';
import 'package:med_assistance_frontend/screens/recording/recording_screen.dart';
import 'package:med_assistance_frontend/services/content_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_assistance_frontend/services/patient_service.dart';

class PreRecordingScreen extends StatefulWidget {
  const PreRecordingScreen({Key? key}) : super(key: key);

  @override
  _PreRecordingScreenState createState() => _PreRecordingScreenState();
}

class _PreRecordingScreenState extends State<PreRecordingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _procedureController = TextEditingController();
  String? _selectedProcedureType;
  String? _selectedExactProcedureName;
  List<String> _filteredProcedureOptions = [];
  List<Map<String, dynamic>> _patients = [];

  String? _selectedPatientId;
  String? _doctorId;
  bool _isPatientListEmpty = false;
  bool _isLoading = true;

  final PatientService _patientService = PatientService();
  Map<String, List<String>> _procedureOptions = {
    'Cirurgias': [],
    'Consulta': [],
  };

  @override
  void initState() {
    super.initState();
    _procedureController.addListener(_filterProcedureOptions);
    _loadInitialData();
  }

  @override
  void dispose() {
    _procedureController.removeListener(_filterProcedureOptions);
    _patientController.dispose();
    _procedureController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadDoctorId();
    await _loadPatients();
    await _loadProcedures();
  }

  Future<void> _loadDoctorId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _doctorId = prefs.getString('doctorId');
    });
  }

  Future<void> _loadPatients() async {
    if (_doctorId != null) {
      try {
        List<Map<String, dynamic>> patients =
            await _patientService.getPatients();
        setState(() {
          _patients = patients;
          _isPatientListEmpty = _patients.isEmpty;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar pacientes: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar o ID do médico')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadProcedures() async {
    try {
      final cirurgiasData = await fetchAndCacheContent('cirurgias');
      final consultasData = await fetchAndCacheContent('consultas');

      setState(() {
        _procedureOptions = {
          'Cirurgias':
              cirurgiasData.map((item) => item['name'].toString()).toList(),
          'Consulta':
              consultasData.map((item) => item['name'].toString()).toList(),
        };
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar procedimentos: $error')),
      );
    }
  }

  void _filterProcedureOptions() {
    if (_selectedProcedureType != null) {
      setState(() {
        _filteredProcedureOptions = _procedureOptions[_selectedProcedureType]!
            .where((option) => option
                .toLowerCase()
                .contains(_procedureController.text.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Novo Procedimento"),
        centerTitle: true,
      ),
      body: BackgroundContainer(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isPatientListEmpty
                              ? _buildNoPatientsMessage()
                              : Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildProcedureTypeDropdown(),
                                      const SizedBox(height: 16),
                                      _buildPatientField(),
                                      const SizedBox(height: 16),
                                      _buildProcedureNameField(),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _submitForm,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                          ),
                                          child: const Text(
                                            'Continuar',
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildNoPatientsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum paciente encontrado.',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre um paciente antes de continuar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _navigateToPatientRegistration,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Cadastrar Paciente',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPatientRegistration() {
    Navigator.pushNamed(context, '/patientregistration');
  }

  Widget _buildProcedureTypeDropdown() {
    return _buildLabeledDropdownField<String>(
      label: 'Tipo de Procedimento',
      value: _selectedProcedureType,
      items: _procedureOptions.keys.toList(),
      icon: Icons.local_hospital,
      onChanged: (value) {
        setState(() {
          _selectedProcedureType = value;
          _selectedExactProcedureName = null;
          _filteredProcedureOptions = _procedureOptions[value] ?? [];
          _procedureController.clear();
          _filterProcedureOptions();
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione o tipo de procedimento';
        }
        return null;
      },
    );
  }

  Widget _buildPatientField() {
    return _buildLabeledTypeAheadField<Map<String, dynamic>>(
      controller: _patientController,
      label: 'Paciente',
      hintText: 'Digite para buscar...',
      icon: Icons.person,
      suggestionsCallback: (pattern) {
        return _patients.where((patient) =>
            patient['name'].toLowerCase().contains(pattern.toLowerCase()));
      },
      itemBuilder: (context, Map<String, dynamic> suggestion) {
        return ListTile(
          title: Text(suggestion['name']),
          subtitle: Text('CPF: ${suggestion['cpf']}'),
        );
      },
      onSuggestionSelected: (suggestion) {
        setState(() {
          _patientController.text = suggestion['name'];
          _selectedPatientId = suggestion['id'];
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione um paciente';
        }
        if (!_patients.any((patient) =>
            patient['name'].toLowerCase() == value.toLowerCase())) {
          return 'Paciente não encontrado. Selecione um paciente válido.';
        }
        return null;
      },
    );
  }

  Widget _buildProcedureNameField() {
    return GestureDetector(
      onTap: () {
        if (_selectedProcedureType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecione o tipo de procedimento primeiro.'),
            ),
          );
        }
      },
      child: AbsorbPointer(
        absorbing: _selectedProcedureType == null,
        // Impede a interação se o tipo não estiver selecionado
        child: _buildLabeledTypeAheadField<String>(
          controller: _procedureController,
          label: 'Procedimento',
          hintText: 'Digite para buscar...',
          icon: Icons.medical_services,
          enabled: _selectedProcedureType != null,
          // Desabilita o campo se não houver tipo selecionado
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
              _procedureController.text = suggestion;
              _selectedExactProcedureName = suggestion;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, selecione o nome exato do procedimento';
            }
            if (!_filteredProcedureOptions
                .any((option) => option.toLowerCase() == value.toLowerCase())) {
              return 'Procedimento não encontrado. Selecione um procedimento válido.';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildLabeledTypeAheadField<T>({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required SuggestionsCallback<T> suggestionsCallback,
    required ItemBuilder<T> itemBuilder,
    required SuggestionSelectionCallback<T> onSuggestionSelected,
    FormFieldValidator<String>? validator,
    bool enabled = true, // Parâmetro para controlar se o campo está habilitado
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          '$label *',
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        // TypeAheadField
        TypeAheadFormField<T>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: controller,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(icon, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade100.withOpacity(0.8),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              labelStyle: const TextStyle(color: Colors.grey),
            ),
          ),
          suggestionsCallback: suggestionsCallback,
          itemBuilder: itemBuilder,
          onSuggestionSelected: onSuggestionSelected,
          validator: validator,
          noItemsFoundBuilder: (context) => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildLabeledDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required IconData icon,
    required ValueChanged<T?> onChanged,
    FormFieldValidator<T>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          '$label *',
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        // Dropdown
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey.shade100.withOpacity(0.8),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
          ),
          dropdownColor: Colors.white,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      bool isValidPatient = _patients.any((patient) =>
          patient['name'].toLowerCase() ==
          _patientController.text.toLowerCase());
      if (!isValidPatient) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione um paciente válido.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!_filteredProcedureOptions.any((option) =>
          option.toLowerCase() == _selectedExactProcedureName?.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione um procedimento válido.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      bool confirmed = await _showConfirmationDialog();
      if (!confirmed) return;

      var procedureData = {
        'paciente_id': _selectedPatientId,
        'medico_id': _doctorId,
        'tipo': _selectedProcedureType,
        'procedimento': _selectedExactProcedureName,
      };

      _navigateToRecordingScreen(procedureData);
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmação de Dados'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    _buildConfirmationText(
                        'Tipo de Procedimento', _selectedProcedureType ?? ''),
                    _buildConfirmationText('Paciente', _patientController.text),
                    _buildConfirmationText(
                        'Procedimento', _selectedExactProcedureName ?? ''),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ElevatedButton(
                  child: const Text('Confirmar'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _buildConfirmationText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRecordingScreen(Map<String, dynamic> procedureData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordingScreen(procedureData: procedureData),
      ),
    );
  }
}
