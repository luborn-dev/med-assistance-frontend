import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final Function(String) onSearch;
  final String label;

  const SearchField({Key? key, required this.onSearch, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
      onChanged: (value) => onSearch(value),
    );
  }
}
