import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GradientContainer extends StatelessWidget {
  final Widget child;

  const GradientContainer({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.blue.shade400],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: child,
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _affiliationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _emailController.text = prefs.getString('email') ?? 'Erro';
        _usernameController.text = prefs.getString('userName') ?? 'Erro';
        _affiliationController.text = prefs.getString('affiliation') ?? 'Erro';
      });
    } catch (e) {
      print("Erro ao carregar dados do usuário: $e");
    }
  }

  Future<void> _saveUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _emailController.text);
      await prefs.setString('userName', _usernameController.text);
      await prefs.setString('affiliation', _affiliationController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dados salvos com sucesso!")),
      );
    } catch (e) {
      print("Erro ao salvar dados do usuário: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao salvar os dados.")),
      );
    }
  }

  Future<void> _updatePassword(String oldPassword, String newPassword) async {
    try {
      var url = Uri.parse('http://172.20.10.3:8000/api/users/update_password');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var email = prefs.getString('email');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Senha atualizada com sucesso!")),
        );
      } else {
        var error = jsonDecode(response.body)['detail'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao atualizar a senha: $error")),
        );
      }
    } catch (e) {
      print("Error updating password: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro interno. Por favor, tente novamente mais tarde.")),
      );
    }
  }

  void _showChangePasswordDialog() {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mudar Senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha Antiga'),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova Senha'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                _updatePassword(oldPasswordController.text, newPasswordController.text);
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Você tem certeza que deseja aplicar as mudanças?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sim'),
              onPressed: () {
                Navigator.of(context).pop();
                _saveUserData();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GradientContainer(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLabeledTextField("Email", _emailController, "Digite seu email"),
                    const SizedBox(height: 10),
                    _buildLabeledTextField("Usuário", _usernameController, "Digite seu usuário"),
                    const SizedBox(height: 10),
                    _buildLabeledTextField("Afiliação", _affiliationController, "Digite sua afiliação"),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 220, // Definir largura fixa para o botão
                      child: ElevatedButton(
                        onPressed: _showConfirmationDialog,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green.shade700,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 5,
                        ),
                        child: const Text('Aplicar', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 220, // Definir largura fixa para o botão
                      child: ElevatedButton(
                        onPressed: _showChangePasswordDialog,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue.shade700,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 5,
                        ),
                        child: const Text('Mudar Senha', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 32,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/main');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledTextField(String label, TextEditingController controller, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 300,
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(width: 2, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
