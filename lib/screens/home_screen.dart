import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_assistance_frontend/components/background_container.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String userName = 'Usuário';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = (prefs.getString('name')?.split(" ").first) ?? 'Usuário';
    });
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Bem-vindo, $userName!",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _showLogoutConfirmationDialog(context),
          ),
        ],
      ),
      body: BackgroundContainer(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Image(
                image: AssetImage('assets/logo_no_text.png'),
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildActionCard(
                      title: "Cadastrar Paciente",
                      icon: Icons.person_add,
                      color: Colors.blue[400]!,
                      onTap: () =>
                          Navigator.pushNamed(context, "/patientregistration"),
                    ),
                    _buildActionCard(
                      title: "Iniciar Gravação",
                      icon: Icons.mic,
                      color: Colors.blue[400]!,
                      onTap: () =>
                          Navigator.pushNamed(context, "/preRecording"),
                    ),
                    _buildActionCard(
                      title: "Gerenciar Gravações",
                      icon: Icons.manage_search,
                      color: Colors.blue[400]!,
                      onTap: () =>
                          Navigator.pushNamed(context, "/manageRecordings"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: "Perfil"),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: "FAQ",
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Já está na tela Home, não faz nada.
          } else if (index == 1) {
            Navigator.pushNamed(context, "/manageAccount");
          } else if (index == 2) {
            Navigator.pushNamed(context, "/faq");
          }
        },
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
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
                foregroundColor: Colors.grey,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Não'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
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
