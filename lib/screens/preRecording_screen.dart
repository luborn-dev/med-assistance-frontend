import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/screens/recording_screen.dart';

class PreRecordingScreen extends StatefulWidget {
  const PreRecordingScreen({Key? key}) : super(key: key);

  @override
  _PreRecordingScreenState createState() => _PreRecordingScreenState();
}

class _PreRecordingScreenState extends State<PreRecordingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _exactProcedureNameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  String? _selectedProcedureType;

  void _navigateToRecordingScreen(Map<String, dynamic> procedureData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordingScreen(procedureData: procedureData),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      var procedureData = {
        'procedure_type': _selectedProcedureType,
        'patient_name': _patientNameController.text,
        'exact_procedure_name': _exactProcedureNameController.text,
        'birthdate': _birthdateController.text,
      };

      // Navegar para a RecordingScreen com os dados do procedimento
      _navigateToRecordingScreen(procedureData);
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _exactProcedureNameController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _birthdateController.text = "${picked.toLocal()}".split(' ')[0]; // Formatar a data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Informações do Procedimento"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedProcedureType,
                decoration: const InputDecoration(
                  labelText: "Tipo de Procedimento",
                  border: OutlineInputBorder(),
                ),
                items: ['Cirurgia', 'Exame', 'Consulta']
                    .map((label) => DropdownMenuItem(
                  child: Text(label),
                  value: label,
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProcedureType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o tipo de procedimento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _buildTextField(_patientNameController, "Nome do Paciente"),
              const SizedBox(height: 10),
              _buildTextField(_exactProcedureNameController, "Nome Exato do Procedimento"),
              const SizedBox(height: 10),
              TextFormField(
                controller: _birthdateController,
                decoration: InputDecoration(
                  labelText: "Data de Nascimento",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione a data de nascimento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Continuar para Gravação'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, preencha este campo';
        }
        return null;
      },
    );
  }
}
