import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/components/bottom_navigation.dart';
import 'package:med_assistance_frontend/services/access/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_assistance_frontend/components/background_container.dart';
import 'package:med_assistance_frontend/utils/state_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _crmController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  String userId = '';
  bool _hasChanges = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      _nameController.text = prefs.getString('name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      final professionalId = prefs.getString('professionalId') ?? '';
      _stateController.text = professionalId.split(' ').first.split('/')[1];
      _crmController.text = professionalId.split(' ').last;
    });
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final professionalId =
          "CRM/${_stateController.text} ${_crmController.text}";

      try {
        await UserService().updateUser(
          userId,
          _nameController.text,
          _emailController.text,
          professionalId,
        );

        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil atualizado com sucesso!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao atualizar perfil: $e")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onFieldChange() {
    setState(() => _hasChanges = true);
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Exclusão"),
          content: const Text(
              "Tem certeza de que deseja deletar sua conta? Essa ação é irreversível."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: _deleteAccount,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Deletar Conta"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    Navigator.of(context).pop();
    try {
      await UserService().deleteUser(userId);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacementNamed(context, '/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Conta deletada com sucesso.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao deletar conta: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nome Completo',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildStateField(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _crmController,
                      label: 'CRM / Registro Profissional',
                      icon: Icons.badge,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _hasChanges ? _saveUserData : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              )
                            : const Text(
                                'Salvar',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: GestureDetector(
                          onTap: _showDeleteAccountDialog,
                          child: const Text(
                            'Deletar Conta',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/main');
          if (index == 2) {
            Navigator.pushReplacementNamed(context, '/faq');
          }
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      onChanged: (_) => _onFieldChange(),
      decoration: InputDecoration(
        labelText: label,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira $label';
        }
        return null;
      },
    );
  }

  Widget _buildStateField() {
    return TextFormField(
      controller: _stateController,
      readOnly: true,
      onTap: _showStatePicker,
      decoration: InputDecoration(
        labelText: 'Estado (UF)',
        hintText: 'Selecione o Estado',
        prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione o estado';
        }
        return null;
      },
    );
  }

  void _showStatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: StateUtils.states.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(StateUtils.states[index]),
          onTap: () {
            setState(() {
              _stateController.text = StateUtils.states[index];
              _onFieldChange();
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
