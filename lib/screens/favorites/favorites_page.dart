/// A GetX widget that displays the user's favorite recipes.
///
/// The `FavoritesPage` widget fetches and displays a list of favorite meals
/// from the `FavoritesService`. It shows a loading indicator while the data
/// is being fetched and displays a message if no favorite recipes are found.
///
/// When a meal is selected, it navigates to the `RecipePage` to show the
/// details of the selected meal. Upon returning from the `RecipePage`, the
/// list of favorite meals is refreshed.
///
/// The widget consists of:
/// - An `AppBar` with the title "Favorite Recipes".
/// - A body that shows either a loading indicator, a message indicating no
///   favorite recipes, or a grid of favorite meals.
///
/// The favorite meals are displayed using the `MealGrid` widget, which
/// expects the meals data in a map format.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import '../../../services/favorites_service.dart';
import '../../../services/scroll_preloader.dart';
import '../../models/meal_model.dart';
import '../../widgets/meal/meal_grid.dart';
import '../../widgets/state/empty_state_view.dart';
import '../../widgets/scroll/scrollable_wrapper.dart';
import '../../routes/app_routes.dart';

class FavoritesPage extends GetView<FavoritesController> {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    ScrollPreloader? scrollPreloader;

    // Initialize preloading when favorites are loaded
    void initializePreloading() async {
      if (controller.favorites.isEmpty) return;

      // Extract image URLs from favorite meals
      final imageUrls = controller.favorites
          .map((meal) => meal.strMealThumb)
          .where((url) => url.isNotEmpty)
          .toList();

      // Initialize scroll preloader service
      scrollPreloader = ScrollPreloader(imageUrls: imageUrls);
      await scrollPreloader!.initialize(context);

      // Set up scroll listener to delegate to the service
      scrollController.addListener(() {
        scrollPreloader!.onScroll(scrollController);
      });
    }

    void onMealSelected(Meal meal) {
      Get.toNamed(
        AppRoutes.recipe,
        arguments: {
          AppRoutes.mealIdParam: meal.idMeal,
          AppRoutes.mealNameParam: meal.strMeal,
        },
      )?.then((_) => controller.loadFavorites()); // Refreshing list when returning
    }

    Widget buildContent() {
      return Obx(() {
        // Skeleton only on first load; refreshes after returning keep the current grid
        if (controller.isLoading.value && controller.favorites.isEmpty) {
          return const MealGridSkeleton(itemCount: 4);
        }

        if (controller.favorites.isEmpty) {
          return EmptyStateView(
            icon: Icons.favorite_border_rounded,
            title: TextConstants.noFavoritesMessage,
            message: TextConstants.addFavoritesMessage,
            actionLabel: TextConstants.browseRecipesButton,
            onAction: () => Get.back(),
          );
        }

        final mealsData = controller.favorites.map((meal) => meal.toJson()).toList();

        // Initialize preloading when favorites are available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          initializePreloading();
        });

        return MealGrid(
          meals: mealsData,
          onMealSelected: onMealSelected,
          scrollController: scrollController,
          useCachedImages: true,
        );
      });
    }

    return ScrollableWrapper(
      controller: scrollController,
      title: TextConstants.favoritesTitle,
      subtitle: Obx(() => Text(
            controller.favorites.isEmpty
                ? ''
                : TextConstants.savedRecipeCount(controller.favorites.length),
          )),
      child: buildContent(),
    );
  }
}
