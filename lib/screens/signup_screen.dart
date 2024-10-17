import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:med_assistance_frontend/widget/gradient_container.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _affiliationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _showLoadingDialog();
      var startTime = DateTime.now();

      try {
        var url = Uri.parse('http://172.20.10.3:8000/api/users/register');
        var response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'affiliation': _affiliationController.text,
          }),
        );

        var endTime = DateTime.now();
        var difference = endTime.difference(startTime);
        if (difference < const Duration(seconds: 2)) {
          await Future.delayed(const Duration(seconds: 2) - difference);
        }

        Navigator.of(context).pop();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cadastro realizado com sucesso!")),
          );
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushReplacementNamed(context, '/welcome');
        } else {
          var error = jsonDecode(response.body)['detail'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro: $error")),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // Fecha o diálogo de carregamento
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _affiliationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Center(
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
                            _buildTextField(_usernameController, 'Usuário'),
                            const SizedBox(height: 16),
                            _buildTextField(_emailController, 'E-mail'),
                            const SizedBox(height: 16),
                            _buildTextField(_passwordController, 'Senha', obscureText: true),
                            const SizedBox(height: 16),
                            _buildTextField(_affiliationController, 'Afiliação'),
                          ],
                        ),
                      ),
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
                          onPressed: _register,
                          child: const Text('Cadastrar', style: TextStyle(fontSize: 20)),
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
