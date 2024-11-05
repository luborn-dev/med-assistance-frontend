import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/components/background_container.dart';
import 'package:med_assistance_frontend/components/bottom_navigation.dart';
import 'package:med_assistance_frontend/services/content_service.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  _FaqScreenState createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ContentService _contentService = ContentService();
  List<Map<String, dynamic>> faqs = [];
  List<Map<String, dynamic>> filteredFaqs = [];
  List<bool> isExpandedList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFaqs();
    _searchController.addListener(_filterFaqs);
  }

  void _fetchFaqs() async {
    try {
      List<Map<String, dynamic>> fetchedFaqs =
          await _contentService.fetchContentsByType("faq");
      setState(() {
        faqs = fetchedFaqs;
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
              (faq['question'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(query) ||
              (faq['answer'] ?? '').toString().toLowerCase().contains(query))
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
