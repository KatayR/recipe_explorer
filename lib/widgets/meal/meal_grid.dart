import 'package:flutter/material.dart';
import 'package:recipe_explorer/models/meal_model.dart';
import '../../constants/ui_constants.dart';
import '../loading/loading_view.dart';
import 'meal_card.dart';
import '../../utils/responsive_helper.dart';

/// Outer padding of every meal grid (bottom inset is added on top of this).
const EdgeInsets _gridPadding = EdgeInsets.fromLTRB(
  UIConstants.doublePadding,
  UIConstants.defaultPadding,
  UIConstants.doublePadding,
  UIConstants.sectionSpacing,
);

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
    final padding = _gridPadding.copyWith(
      bottom: _gridPadding.bottom + MediaQuery.paddingOf(context).bottom,
    );

    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        controller: scrollController,
        padding: padding,
        // Columns and row extent depend on screen size and available width
        gridDelegate: ResponsiveHelper.mealGridDelegate(
          context,
          constraints.maxWidth - padding.horizontal,
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
      ),
    );
  }
}

/// Static placeholder grid shown while meals are loading, laid out exactly like [MealGrid].
class MealGridSkeleton extends StatelessWidget {
  final int itemCount;

  const MealGridSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final placeholder = colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);

    Widget bar(double widthFactor) => FractionallySizedBox(
          widthFactor: widthFactor,
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: placeholder,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );

    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: _gridPadding,
        gridDelegate: ResponsiveHelper.mealGridDelegate(
          context,
          constraints.maxWidth - _gridPadding.horizontal,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Container(color: placeholder)),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(0.9),
                    const SizedBox(height: 8),
                    bar(0.6),
                    const SizedBox(height: 14),
                    bar(0.35),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
