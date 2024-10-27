import 'package:flutter/material.dart';
import 'package:recipe_explorer/constants/text_constants.dart';

class RecipeIngredientsSection extends StatelessWidget {
  final List<String> ingredients;
  final List<String> measures;

  const RecipeIngredientsSection({
    super.key,
    required this.ingredients,
    required this.measures,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          TextConstants.ingredientsTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          ingredients.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '• ${ingredients[index]} - ${measures[index]}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
