import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/components/background_container.dart';
import 'package:med_assistance_frontend/components/bottom_navigation.dart';
import 'package:med_assistance_frontend/components/search_field.dart';

import '../../services/content_service.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  _FaqScreenState createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  List<Map<String, dynamic>> faqs = [];
  List<Map<String, dynamic>> filteredFaqs = [];
  List<bool> isExpandedList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFaqs();
  }

  void _fetchFaqs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> fetchedFaqs = await fetchAndCacheContent("faq");
      setState(() {
        faqs = List<Map<String, dynamic>>.from(fetchedFaqs);
        filteredFaqs = faqs;
        _initializeIsExpandedList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Erro ao carregar FAQs: $e");
    }
  }

  void _initializeIsExpandedList() {
    isExpandedList = List.generate(filteredFaqs.length, (index) => false);
  }

  void _filterFaqs(String query) {
    setState(() {
      filteredFaqs = faqs
          .where((faq) =>
              (faq['question'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (faq['answer'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
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
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SearchField(
                  onSearch: (value) => _filterFaqs(value),
                  label: "Digite uma palavra-chave para encontrar respostas",
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: filteredFaqs.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> faq = entry.value;
                          return _buildFaqCard(faq, index);
                        }).toList(),
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/main');
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/manageAccount');
          }
        },
      ),
    );
  }

  Widget _buildFaqCard(Map<String, dynamic> faq, int index) {
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
          color: Colors.blue[100]!.withOpacity(0.3),
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
                    (faq['question'] ?? '').toString(),
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
                  (faq['answer'] ?? '').toString(),
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
