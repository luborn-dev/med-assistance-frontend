import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:med_assistance_frontend/components/background_container.dart';
import 'package:med_assistance_frontend/services/patient_service.dart';
import 'package:med_assistance_frontend/utils/cpf_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({Key? key}) : super(key: key);

  @override
  _PatientRegistrationScreenState createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _gender;

  final PatientService _patientService = PatientService();
  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _zipCodeFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _loadDoctorId();
  }

  Future<void> _loadDoctorId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('pt'),
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthdateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _fetchAddressByZipCode() async {
    final zipCode = _zipCodeController.text.replaceAll(RegExp(r'\D'), '');
    print(zipCode);
    if (zipCode.length == 8) {
      try {
        final data = await _patientService.fetchAddressByZipCode(zipCode);
        setState(() {
          _streetController.text = data['street'] ?? '';
          _cityController.text = data['city'] ?? '';
          _stateController.text = data['state'] ?? '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _registerPatient() async {
    if (_formKey.currentState!.validate()) {
      bool confirmed = await _showConfirmationDialog();
      if (!confirmed) return;

      _showLoadingDialog();

      final patientData = {
        'name': _nameController.text,
        'birth_date': _birthdateController.text,
        'gender': _gender,
        'cpf': _cpfController.text,
        'contact': _phoneController.text,
        'address': {
          'street': _streetController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'cep': _zipCodeController.text,
          'number': _numberController.text,
        },
      };

      await _patientService.registerPatient(patientData, context);
      Navigator.of(context).pop();
      _clearForm();
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
                    _buildConfirmationText('Nome', _nameController.text),
                    _buildConfirmationText(
                        'Data de Nascimento', _birthdateController.text),
                    _buildConfirmationText('Gênero', _gender ?? ''),
                    _buildConfirmationText('CPF', _cpfController.text),
                    _buildConfirmationText('Telefone', _phoneController.text),
                    const SizedBox(height: 10),
                    const Text(
                      'Endereço',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildConfirmationText('CEP', _zipCodeController.text),
                    _buildConfirmationText('Rua', _streetController.text),
                    _buildConfirmationText('Número', _numberController.text),
                    _buildConfirmationText('Cidade', _cityController.text),
                    _buildConfirmationText('Estado', _stateController.text),
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

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  "Processando...",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _clearForm() {
    _nameController.clear();
    _birthdateController.clear();
    _cpfController.clear();
    _zipCodeController.clear();
    _streetController.clear();
    _cityController.clear();
    _stateController.clear();
    _numberController.clear();
    _phoneController.clear();
    setState(() {
      _gender = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _cpfController.dispose();
    _zipCodeController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _numberController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Cadastro de Paciente"),
        centerTitle: true,
      ),
      body: BackgroundContainer(
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      _buildSectionTitle('Dados pessoais'),
                      const SizedBox(height: 16),
                      _buildTextField(_nameController, 'Nome Completo',
                          icon: Icons.person),
                      const SizedBox(height: 16),
                      _buildLabeledDateField(
                          "Data de Nascimento", _birthdateController, context),
                      const SizedBox(height: 16),
                      _buildDropdownField("Gênero", icon: Icons.wc),
                      const SizedBox(height: 16),
                      _buildTextField(_cpfController, 'CPF',
                          icon: Icons.badge,
                          inputFormatters: [_cpfFormatter],
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildTextField(_phoneController, 'Telefone',
                          icon: Icons.phone,
                          inputFormatters: [_phoneFormatter],
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Endereço'),
                      const SizedBox(height: 10),
                      _buildTextField(_zipCodeController, 'CEP',
                          icon: Icons.location_on,
                          inputFormatters: [_zipCodeFormatter],
                          keyboardType: TextInputType.number,
                          onChanged: (_) => {
                                if (_zipCodeController.text.length == 9)
                                  {_fetchAddressByZipCode()}
                              }),
                      const SizedBox(height: 16),
                      _buildTextField(_streetController, 'Rua',
                          icon: Icons.streetview),
                      const SizedBox(height: 16),
                      _buildTextField(_numberController, 'Número',
                          icon: Icons.house),
                      const SizedBox(height: 16),
                      _buildTextField(_cityController, 'Cidade',
                          icon: Icons.location_city),
                      const SizedBox(height: 16),
                      _buildTextField(_stateController, 'Estado',
                          icon: Icons.map),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _registerPatient,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text(
                            'Cadastrar',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    IconData? icon,
    IconButton? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, preencha este campo';
        }
        if (controller == _phoneController) {
          String pattern = r'^\(\d{2}\) \d{5}-\d{4}$';
          RegExp regex = RegExp(pattern);
          if (!regex.hasMatch(value)) {
            return 'Por favor, insira um telefone válido';
          }
        }
        if (controller == _cpfController && !CPFValidator.validarCPF(value)) {
          return 'Por favor, insira um CPF válido';
        }

        return null;
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildDropdownField(String label, {IconData? icon}) {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      items: ['Masculino', 'Feminino', 'Outro']
          .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _gender = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione o gênero';
        }
        return null;
      },
    );
  }

  Widget _buildLabeledDateField(
      String label, TextEditingController controller, BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      inputFormatters: [_birthdateFormatter],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
      ),
      onTap: () => _selectDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione a data de nascimento';
        }
        return null;
      },
    );
  }

  final _birthdateFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );
}
