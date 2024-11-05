import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final Function(String) onSearch;

  const SearchField({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Buscar',
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (value) => onSearch(value),
    );
  }
}
