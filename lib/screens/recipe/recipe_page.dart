import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import 'package:recipe_explorer/constants/ui_constants.dart';
import 'package:recipe_explorer/widgets/error/error_view.dart';
import '../../../services/api_service.dart';
import '../../../services/favorites_service.dart';
import '../../models/meal_model.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/loading/loading_view.dart';
import 'widgets/instructions.dart';
import 'widgets/header.dart';
import 'widgets/ingredients.dart';
import 'widgets/metadata.dart';

class RecipePageController extends GetxController {
  final ApiController _apiController = Get.find<ApiController>();
  final FavoritesController _favoritesController = Get.find<FavoritesController>();

  var meal = Rx<Meal?>(null);
  var isLoading = true.obs;
  var error = Rx<String?>(null);

  /// Whether the hero header is scrolled into its collapsed (toolbar) state.
  final isCollapsed = false.obs;

  String get mealId => _mealId;
  String get mealName => _mealName;
  
  late String _mealId;
  late String _mealName;

  void initialize(String mealId, String mealName) {
    _mealId = mealId;
    _mealName = mealName;
    loadMealDetails();
  }

  bool get isFavorite => _favoritesController.isFavorite(mealId);

  /// Loads the details of the meal.
  ///
  /// This method first checks if the meal is saved as a favorite. If it is,
  /// it loads the saved details. Otherwise, it fetches the meal details from
  /// the API. If an error occurs during the fetch, an error message is displayed.
  Future<void> loadMealDetails() async {
    isLoading.value = true;
    error.value = null;

    final savedMeal = await _favoritesController.loadMealIfSaved(mealId);
    if (savedMeal != null) {
      meal.value = savedMeal;
      isLoading.value = false;
      return;
    }

    final response = await _apiController.searchMealsByName(mealName);
    isLoading.value = false;
    if (response.error != null) {
      error.value = TextConstants.recipeLoadingError;
    } else if (response.data != null && response.data!.isNotEmpty) {
      meal.value = Meal.fromJson(response.data!.first);
    } else {
      error.value = 'Meal not found';
    }
  }

  /// Toggles the favorite status of the meal.
  ///
  /// This method updates the favorite status of the meal by calling the
  /// [FavoritesController]. If the meal is marked as a favorite, it is saved;
  /// otherwise, it is removed from the favorites.
  Future<void> toggleFavorite() async {
    if (meal.value == null) return;
    await _favoritesController.toggleFavorite(meal.value!);
  }
}

class RecipePage extends GetView<RecipePageController> {
  final String mealId;
  final String mealName;

  const RecipePage({
    super.key,
    required this.mealId,
    required this.mealName,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller with meal data only if not already created
    Get.lazyPut(() => RecipePageController(), tag: mealId);
    final controller = Get.find<RecipePageController>(tag: mealId);
    controller.initialize(mealId, mealName);

    return Obx(() {
      final meal = controller.meal.value;
      if (controller.isLoading.value ||
          controller.error.value != null ||
          meal == null) {
        return Scaffold(
          appBar: AppBar(title: Text(mealName)),
          body: _buildState(controller),
        );
      }
      return _buildDetail(context, controller, meal);
    });
  }

  /// Builds the loading / error / empty states shown before a meal is available.
  Widget _buildState(RecipePageController controller) {
    if (controller.isLoading.value) {
      return const LoadingView();
    }

    if (controller.error.value != null) {
      return ErrorView(
        onRetry: controller.loadMealDetails,
        errString: controller.error.value!,
      );
    }

    return const Center(child: Text(TextConstants.noMealDetailsError));
  }

  /// Builds the recipe itself: collapsing photo header, title, meta chips,
  /// then ingredients and steps (side by side on wide screens).
  Widget _buildDetail(
    BuildContext context,
    RecipePageController controller,
    Meal meal,
  ) {
    final theme = Theme.of(context);
    final isWide = !ResponsiveHelper.isMobile(context);
    final heroHeight =
        isWide ? UIConstants.recipeHeroHeightWide : UIConstants.recipeHeroHeight;
    // Scroll offset at which the pinned toolbar fully covers the photo
    final collapseOffset =
        heroHeight - kToolbarHeight - MediaQuery.paddingOf(context).top;

    final ingredients = RecipeIngredientsSection(
      ingredients: meal.ingredients,
      measures: meal.measures,
    );
    final instructions = RecipeInstructionsSection(
      instructions: meal.strInstructions,
    );

    return Scaffold(
      // Scroll notifications track user scrolling; metrics notifications cover
      // size changes (rotation/resizing) that move the offset without a scroll.
      body: NotificationListener<Notification>(
        onNotification: (notification) {
          final ScrollMetrics? metrics = switch (notification) {
            ScrollNotification(depth: 0) => notification.metrics,
            ScrollMetricsNotification(depth: 0) => notification.metrics,
            _ => null,
          };
          if (metrics != null) {
            controller.isCollapsed.value = metrics.pixels > collapseOffset;
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            RecipeHeader(
              mealId: meal.idMeal,
              imageUrl: meal.strMealThumb,
              title: meal.strMeal,
              expandedHeight: heroHeight,
              isCollapsed: controller.isCollapsed,
              isFavorite: () => controller.isFavorite,
              onToggleFavorite: controller.toggleFavorite,
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: UIConstants.recipeContentMaxWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      UIConstants.pagePadding,
                      UIConstants.sectionSpacing,
                      UIConstants.pagePadding,
                      UIConstants.sectionSpacing +
                          MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meal.strMeal, style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        RecipeMetadataSection(
                          category: meal.strCategory,
                          area: meal.strArea,
                        ),
                        const SizedBox(height: 28),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: ingredients),
                              const SizedBox(width: 40),
                              Expanded(flex: 3, child: instructions),
                            ],
                          )
                        else ...[
                          ingredients,
                          const SizedBox(height: 32),
                          instructions,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
