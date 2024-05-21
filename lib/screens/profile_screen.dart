import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: "Marcos Silva Caetano");
  final TextEditingController _crmController = TextEditingController(text: "CRM/SP 123355");
  final TextEditingController _cpfController = TextEditingController(text: "111.222.333-77");

  bool _isEditingPassword = false;
  final TextEditingController _passwordController = TextEditingController(text: "**************");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minha conta"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildTextField(_nameController, "Usuário"),
            SizedBox(height: 10),
            _buildTextField(_crmController, "CRM"),
            SizedBox(height: 10),
            _buildTextField(_cpfController, "CPF"),
            SizedBox(height: 20),
            ListTile(
              title: TextField(
                controller: _passwordController,
                obscureText: !_isEditingPassword,
                decoration: InputDecoration(
                  labelText: 'Alterar senha',
                ),
              ),
              trailing: Switch(
                value: _isEditingPassword,
                onChanged: (bool value) {
                  setState(() {
                    _isEditingPassword = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Logic to apply changes
                    },
                    child: Text('Aplicar'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // background
                    ),
                    child: const Text('Retornar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
