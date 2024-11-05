import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  void _logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usando uma cor de fundo sólida
      body: Container(
        color: Colors.white, // Fundo branco para um visual clean
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        width: double.infinity,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 64.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Procedimentos",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildCategoryCard('Cadastrar Paciente', Icons.person_add, context, "/patientregistration"),
                      _buildCategoryCard('Iniciar nova gravação', Icons.mic, context, "/preRecording"),
                      _buildCategoryCard('Gerenciar gravações', Icons.manage_search, context, "/manageRecordings"),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Geral",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildCategoryCard('Minha conta', Icons.account_circle, context, "/manageAccount"),
                      _buildCategoryCard('FAQ', Icons.help_outline, context, "/faq"),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: Icon(Icons.logout, color: Theme.of(context).primaryColor),
                onPressed: () {
                  _showLogoutConfirmationDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, BuildContext context, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0), // Cantos menos arredondados
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Sombra mais sutil
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.2)), // Borda sutil
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14, // Fonte um pouco menor para melhor proporção
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmação de Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Você tem certeza que deseja sair?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Sim'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }
}
