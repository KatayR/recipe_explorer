import 'package:flutter/material.dart';
import '/widgets/meal_list/meal_card.dart';

class MealGrid extends StatelessWidget {
  final List<dynamic> meals;
  final Function(String) onMealSelected;
  final ScrollController? scrollController;

  const MealGrid({
    super.key,
    required this.meals,
    required this.onMealSelected,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return MealCard(
          meal: meal,
          onTap: () => onMealSelected(meal['strMeal']),
        );
      },
    );
  }
}
