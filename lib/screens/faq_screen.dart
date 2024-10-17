import 'package:flutter/material.dart';

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

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    const Text(
                      'Perguntas Frequentes',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFaqItem(
                      'Como faço para alterar minha senha?',
                      'Para alterar sua senha, vá para a tela "Minha conta" e clique em "Mudar Senha". Você precisará inserir sua senha antiga e a nova senha.',
                    ),
                    const SizedBox(height: 20),
                    _buildFaqItem(
                      'Como posso gerenciar minhas gravações?',
                      'Na tela principal, clique em "Gerenciar gravações". Lá você poderá visualizar, excluir e gerenciar todas as suas gravações.',
                    ),
                    const SizedBox(height: 20),
                    _buildFaqItem(
                      'Como faço para adicionar um novo paciente?',
                      'Na tela principal, clique em "Cadastrar Paciente". Preencha o formulário com as informações do paciente e clique em "Salvar".',
                    ),
                    const SizedBox(height: 20),
                    _buildFaqItem(
                      'Posso editar minha afiliação?',
                      'Sim, vá para a tela "Minha conta" e edite o campo de afiliação. Clique em "Aplicar" para salvar as alterações.',
                    ),
                    const SizedBox(height: 20),
                    _buildFaqItem(
                      'O que fazer se eu esquecer minha senha?',
                      'Se você esquecer sua senha, vá para a tela de login e clique em "Esqueceu a senha?". Siga as instruções para redefinir sua senha.',
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

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
