import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/components/background_container.dart';
import 'package:med_assistance_frontend/services/access/login_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final LoginService _loginService = LoginService();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        var userData = await _loginService.login(
          _emailController.text,
          _passwordController.text,
        );

        _navigateToMainScreen(userData);
      } catch (e) {
        _showErrorSnackBar(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToMainScreen(Map<String, dynamic> userData) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login realizado com sucesso!")),
    );
    Navigator.pushReplacementNamed(context, '/main');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erro: $message")),
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
      body: BackgroundContainer(
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Image(
                    image: AssetImage('assets/logo.png'),
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          _emailController,
                          'E-mail',
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _passwordController,
                          'Senha',
                          obscureText: true,
                          icon: Icons.lock,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            )
                                : const Text(
                              'Login',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/forgotPassword');
                          },
                          child: const Text(
                            'Esqueceu a senha?',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Novo por aqui? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: const Text(
                                'Cadastre-se',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool obscureText = false,
        IconData? icon,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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
}
