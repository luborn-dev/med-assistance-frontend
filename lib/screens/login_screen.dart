import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:med_assistance_frontend/widget/gradient_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _showLoadingDialog();
      var startTime = DateTime.now();

      try {
        var url = Uri.parse('http://10.0.2.2:8000/api/users/login');
        var response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        var endTime = DateTime.now();
        var difference = endTime.difference(startTime);
        if (difference < const Duration(seconds: 2)) {
          await Future.delayed(const Duration(seconds: 2) - difference);
        }

        Navigator.of(context).pop(); // Fecha o diálogo de carregamento

        if (response.statusCode == 200) {
          var userData = jsonDecode(response.body);
          print("Login successful. User data: $userData"); // Log dos dados do usuário
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', userData['email']);
          await prefs.setString('userName', userData['username']); // Supondo que o nome do usuário esteja na resposta
          await prefs.setString('affiliation', userData['affiliation']); // Supondo que o nome do usuário esteja na resposta

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login realizado com sucesso!")),
          );
          await Future.delayed(const Duration(milliseconds: 50));
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          var error = jsonDecode(response.body)['detail'];
          print("Login failed. Error: $error"); // Log do erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro: $error")),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // Fecha o diálogo de carregamento
        print("Internal error: $e"); // Log do erro interno
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro interno. Por favor, tente novamente mais tarde.")),
        );
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  "Processando...",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage('assets/logo.png'),
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(_emailController, 'E-mail'),
                          const SizedBox(height: 16),
                          _buildTextField(_passwordController, 'Senha', obscureText: true),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 200, // Ajuste da largura do botão
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 5,
                              ),
                              onPressed: _login,
                              child: const Text('Login', style: TextStyle(fontSize: 20)),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  Navigator.pushReplacementNamed(context, '/welcome');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 280,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(width: 2, color: Colors.white),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, insira $label';
          }
          return null;
        },
      ),
    );
  }
}
