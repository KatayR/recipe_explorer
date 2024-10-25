import 'package:flutter/material.dart';
import '/utils/error_handler.dart';
import '/widgets/meal_list/meal_grid.dart';

class ResultsContent extends StatelessWidget {
  final List<dynamic> meals;
  final bool isLoading;
  final bool hasMore;
  final ScrollController scrollController;
  final Function(String) onMealSelected;

  const ResultsContent({
    required this.meals,
    required this.isLoading,
    required this.hasMore,
    required this.scrollController,
    required this.onMealSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (meals.isEmpty) {
      return ErrorHandler.buildErrorWidget('No results found');
    }

    return MealGrid(
      meals: meals,
      onMealSelected: onMealSelected,
      scrollController: scrollController,
    );
  }
}
