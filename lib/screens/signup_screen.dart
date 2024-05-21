import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

      var url = Uri.parse('http://10.0.2.2:8000/api/users/register');
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

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cadastro realizado com sucesso!")),
        );
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacementNamed(context, '/welcome');
      } else {
        var error = jsonDecode(response.body)['detail'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $error")),
        );
      }
    }
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/welcome');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(64.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('assets/logo.png'),
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(width: 2, color: Colors.black),
                    ),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(160, 40),
                  ),
                  onPressed: _register,
                  child: const Text('Cadastrar'),
                ),
              ],
            ),
          ),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(width: 2, color: Colors.black),
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
