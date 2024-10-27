import 'package:flutter/material.dart';

class RecipeMetadataSection extends StatelessWidget {
  final String category;
  final String area;

  const RecipeMetadataSection({
    super.key,
    required this.category,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category: $category',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Cuisine: $area',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
