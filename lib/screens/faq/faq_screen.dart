import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/components/background_container.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  _FaqScreenState createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> faqs = [
    {
      'question': 'Como gerenciar minhas gravações?',
      'answer':
          'Na tela principal, clique em "Gerenciar gravações". Lá você poderá visualizar, excluir e gerenciar todas as suas gravações.',
    },
    {
      'question': 'Como faço para adicionar um novo paciente?',
      'answer':
          'Na tela principal, clique em "Cadastrar Paciente". Preencha o formulário com as informações do paciente e clique em "Salvar".',
    },
    {
      "question": "Como posso atualizar minhas informações pessoais?",
      "answer":
          "Acesse a seção “Minha Conta” para editar seus dados, como nome, e-mail e CRM."
    },
    {
      'question': 'Como deletar minha conta?',
      'answer': 'Vá para a tela "Minha conta" e clique em "Deletar Conta".',
    },
    {
      "question": "Esqueci minha senha. Como posso redefini-la?",
      "answer":
          "Na tela de login, clique em 'Esqueceu a senha?' e siga as instruções para redefinição."
    },
    {
      "question": "Meus dados são compartilhados com terceiros?",
      "answer":
          "Não, suas informações são mantidas em sigilo e só são compartilhadas com profissionais autorizados mediante seu consentimento."
    },
    {
      "question": "É possível exportar as informações em PDF?",
      "answer":
          "Sim, você pode exportar relatórios e informações em formato PDF diretamente do aplicativo. Acesse a seção de gerenciamento de gravações e selecione a opção 'Exportar para PDF'."
    },
    {
      "question": "Como posso obter ajuda adicional ou suporte técnico?",
      "answer": "Para qualquer dúvida ou suporte técnico, entre em contato com nossa equipe enviando um e-mail para suporte@medassistance.com. Nossa equipe está disponível para ajudar você com quaisquer problemas ou perguntas."
    }
  ];
  List<Map<String, String>> filteredFaqs = [];
  List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    filteredFaqs = faqs;
    _initializeIsExpandedList();
    _searchController.addListener(_filterFaqs);
  }

  void _initializeIsExpandedList() {
    isExpandedList = List.generate(filteredFaqs.length, (index) => false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFaqs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredFaqs = faqs
          .where((faq) =>
              faq['question']!.toLowerCase().contains(query) ||
              faq['answer']!.toLowerCase().contains(query))
          .toList();
      _initializeIsExpandedList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSearchBar(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: filteredFaqs.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, String> faq = entry.value;
                    return _buildFaqCard(faq, index);
                  }).toList(),
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
            icon: Icon(Icons.account_circle),
            label: "Perfil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: "FAQ",
          ),
        ],
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/main');
          if (index == 1)
            Navigator.pushReplacementNamed(context, '/manageAccount');
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Pesquisar...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
    );
  }

  Widget _buildFaqCard(Map<String, String> faq, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpandedList[index] = !isExpandedList[index];
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[100]!.withOpacity(0.3), // Fundo suave azul claro
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.question_answer,
                  color: Colors.blue[400],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    faq['question']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                Icon(
                  isExpandedList[index] ? Icons.expand_less : Icons.expand_more,
                  color: Colors.blue[400],
                ),
              ],
            ),
            if (isExpandedList[index])
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  faq['answer']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
