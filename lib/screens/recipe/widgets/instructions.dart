import 'package:flutter/material.dart';

class RecipeInstructionsSection extends StatelessWidget {
  final String instructions;

  const RecipeInstructionsSection({
    super.key,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instructions:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          instructions,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
