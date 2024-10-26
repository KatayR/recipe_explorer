import 'package:flutter/material.dart';
import 'meal_list_item.dart';

class PaginatedMealList extends StatelessWidget {
  final List<dynamic> meals;
  final bool isLoading;
  final bool hasMore;
  final ScrollController scrollController;
  final Function(String) onMealSelected;

  const PaginatedMealList({
    super.key,
    required this.meals,
    required this.isLoading,
    required this.hasMore,
    required this.scrollController,
    required this.onMealSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: meals.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == meals.length) {
          return isLoading
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                )
              : const SizedBox.shrink();
        }

        final meal = meals[index];
        return MealListItem(
          meal: meal,
          onTap: () => onMealSelected(meal['strMeal']),
        );
      },
    );
  }
}
