import 'package:flutter/material.dart';
import '../../../widgets/meal/meal_grid.dart';
import '../../../models/meal_model.dart';

class PaginatedResults extends StatelessWidget {
  final List<dynamic> displayedMeals;
  final Function(Meal) onMealSelected;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final bool hasMore;

  const PaginatedResults({
    super.key,
    required this.displayedMeals,
    required this.onMealSelected,
    required this.scrollController,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    return MealGrid(
      meals: displayedMeals,
      onMealSelected: onMealSelected,
      scrollController: scrollController,
      isLoading: isLoadingMore,
      hasMore: hasMore,
    );
  }
}
