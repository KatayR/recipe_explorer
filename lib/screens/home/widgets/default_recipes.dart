/// A widget that displays a section of default recipes fetched from an API.
///
/// The `DefaultRecipesSection` widget fetches and displays
/// a list of sample dishes that can be made with chicken. It uses GetX reactive
/// state management and displays data in a grid format. If there is an error during
/// the fetch operation or if the data is still loading, appropriate views are shown.
///
/// Example usage:
/// ```dart
/// DefaultRecipesSection();
/// ```
///
/// The widget consists of:
/// - A title indicating the type of dishes being displayed.
/// - Reactive state management with GetX for loading/error states
/// - A `MealGridSkeleton` that is displayed while the data is being fetched.
/// - An `ErrorView` with retry when the fetch fails.
/// - A `MealGrid` that displays the fetched meals in a grid format.
///
/// When a meal is selected from the grid, the user is navigated to the `RecipePage`
/// for that specific meal.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import 'package:recipe_explorer/constants/ui_constants.dart';
import '../../../services/api_service.dart';
import '../../../services/scroll_preloader.dart';
import '../../../widgets/error/error_view.dart';
import '../../../widgets/meal/meal_grid.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/scroll/scrollable_wrapper.dart';
import '../../../routes/app_routes.dart';

class DefaultRecipesSectionController extends GetxController {
  final ApiController _apiController = Get.find<ApiController>();

  var meals = <dynamic>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadMeals();
  }

  Future<void> loadMeals() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final response = await _apiController.getMealsByCategory('Chicken');
      if (response.data != null) {
        meals.value = response.data!;
      }
      hasError.value = response.error != null || meals.isEmpty;
      isLoading.value = false;
    } catch (e) {
      hasError.value = true;
      isLoading.value = false;
      debugPrint('Error loading meals: $e');
    }
  }
}

class DefaultRecipesSection extends GetView<DefaultRecipesSectionController> {
  const DefaultRecipesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller only if not already created
    Get.lazyPut(() => DefaultRecipesSectionController(), tag: 'default_recipes');
    final controller = Get.find<DefaultRecipesSectionController>(tag: 'default_recipes');
    
    // Get the primary scroll controller which is set by NestedScrollView
    final scrollController = PrimaryScrollController.of(context);
    ScrollPreloader? scrollPreloader;

    void initializePreloading() async {
      if (controller.meals.isEmpty) return;

      // Extract image URLs from meals data
      final imageUrls = controller.meals
          .map((meal) => meal['strMealThumb'] as String)
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            UIConstants.pagePadding,
            0,
            UIConstants.pagePadding,
            UIConstants.defaultPadding,
          ),
          child: SectionHeader(
            title: TextConstants.defaultCategoryTitle,
            subtitle: TextConstants.defaultCategorySubtitle,
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const MealGridSkeleton();
            }

            if (controller.hasError.value) {
              return ErrorView(
                errString: TextConstants.defaultCategoryError,
                onRetry: controller.loadMeals,
              );
            }

            // Initialize preloading when meals are available
            WidgetsBinding.instance.addPostFrameCallback((_) {
              initializePreloading();
            });

            return ScrollableWrapper(
              controller: scrollController,
              useScaffold: false,
              child: MealGrid(
                meals: controller.meals,
                onMealSelected: (meal) => Get.toNamed(
                  AppRoutes.recipe,
                  arguments: {
                    AppRoutes.mealIdParam: meal.idMeal,
                    AppRoutes.mealNameParam: meal.strMeal,
                  },
                ),
                scrollController: scrollController,
              ),
            );
          }),
        ),
      ],
    );
  }
}
