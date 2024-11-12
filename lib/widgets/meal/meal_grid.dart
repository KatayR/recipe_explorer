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
  final bool hasMore; // Flag to indicate if there are more items to load
  final bool useCachedImages; // Parameter to control image caching

  const MealGrid({
    super.key,
    required this.meals,
    required this.onMealSelected,
    this.scrollController,
    this.isLoading = false,
    this.hasMore = false,
    this.useCachedImages = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // Get the number of columns based on screen size
        crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
        // Get the aspect ratio of the grid items based on screen size
        childAspectRatio: ResponsiveHelper.getGridChildAspectRatio(context),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      // Add an extra item if there are more items to load
      itemCount: meals.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // If the index is at the end of the list, show a loading indicator or an empty box
        if (index == meals.length) {
          return isLoading ? const LoadingView() : const SizedBox();
        }

        // Otherwise, show a meal card
        return MealCard(
          meal: meals[index],
          // Call the onMealSelected callback when a meal is tapped
          onTap: () => onMealSelected(Meal.fromJson(meals[index])),
          useCachedImage: useCachedImages,
        );
      },
    );
  }
}
