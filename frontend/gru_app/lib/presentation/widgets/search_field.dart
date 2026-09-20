import 'package:flutter/material.dart';

/// Campo de busca em pílula branca.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Buscar lixeira, endereço ou CEP',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, size: 22),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    );
  }
}
