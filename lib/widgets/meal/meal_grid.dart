import 'package:flutter/material.dart';
import 'package:recipe_explorer/models/meal_model.dart';
import '../loading/loading_view.dart';
import 'meal_card.dart';
import '../../utils/responsive_helper.dart';

class MealGrid extends StatelessWidget {
  final List<dynamic> meals;
  final Function(Meal) onMealSelected;
  final ScrollController? scrollController;
  final bool isLoading;
  final bool hasMore;

  const MealGrid({
    super.key,
    required this.meals,
    required this.onMealSelected,
    this.scrollController,
    this.isLoading = false,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
        childAspectRatio: ResponsiveHelper.getGridChildAspectRatio(context),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: meals.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == meals.length) {
          return isLoading ? const LoadingView() : const SizedBox();
        }

        return MealCard(
          meal: meals[index],
          onTap: () => onMealSelected(Meal.fromJson(meals[index])),
        );
      },
    );
  }
}
