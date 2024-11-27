import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/components/background_container.dart';
import 'package:med_assistance_frontend/services/access/user_service.dart';
import 'package:med_assistance_frontend/utils/state_utils.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _professionalIdController =
  TextEditingController();
  final _stateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final UserService _signupService = UserService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final professionalId =
            "CRM/${_stateController.text} ${_professionalIdController.text}";
        await _signupService.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
          professionalId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Cadastro realizado com sucesso!",
                  style: TextStyle(color: Colors.white))),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erro: ${e.toString()}",
                  style: const TextStyle(color: Colors.white))),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _professionalIdController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Hero(
                  tag: 'logo',
                  child: Image(
                    image: AssetImage('assets/logo.png'),
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_nameController, 'Nome Completo',
                          icon: Icons.person),
                      const SizedBox(height: 16),
                      _buildTextField(_emailController, 'E-mail',
                          icon: Icons.email, hintText: 'exemplo@email.com'),
                      const SizedBox(height: 16),
                      _buildPasswordField(_passwordController, 'Senha',
                          obscureText: !_isPasswordVisible, isPassword: true),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                          _confirmPasswordController, 'Repetir Senha',
                          obscureText: !_isConfirmPasswordVisible,
                          isConfirmPassword: true),
                      const SizedBox(height: 16),
                      _buildStateField(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _professionalIdController,
                        'CRM / Registro Profissional',
                        icon: Icons.badge,
                        hintText: 'Exemplo: 123456',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o CRM';
                          }
                          if (value.length != 6 ||
                              !RegExp(r'^\d{6}$').hasMatch(value)) {
                            return 'O CRM deve ter exatamente 6 dígitos';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
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
                              'Cadastrar',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    "Já tem uma conta? Faça login",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
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
        String? hintText,
        String? Function(String?)? validator,
        TextInputType keyboardType = TextInputType.text,
        int? maxLength,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
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
        counterText: "",
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, preencha este campo.';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller,
      String label, {
        bool obscureText = true,
        bool isPassword = false,
        bool isConfirmPassword = false,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              if (isPassword) {
                _isPasswordVisible = !_isPasswordVisible;
              } else if (isConfirmPassword) {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              }
            });
          },
        ),
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
          return 'Por favor, preencha este campo.';
        }
        if (isConfirmPassword && value != _passwordController.text) {
          return 'As senhas não coincidem';
        }
        return null;
      },
    );
  }

  Widget _buildStateField() {
    return TextFormField(
      controller: _stateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Estado emissão CRM (UF)',
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
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      onTap: () {
        _showStatePicker();
      },
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
      builder: (BuildContext context) {
        return Container(
          height: 300,
          child: ListView.builder(
            itemCount: StateUtils.states.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(StateUtils.states[index]),
                onTap: () {
                  setState(() {
                    _stateController.text = StateUtils.states[index];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}
