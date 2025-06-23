import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import 'package:recipe_explorer/constants/ui_constants.dart';
import 'package:recipe_explorer/widgets/error/error_view.dart';
import '../../../services/api_service.dart';
import '../../../services/favorites_service.dart';
import '../../models/meal_model.dart';
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
    // Initialize controller with meal data
    Get.put(RecipePageController(), tag: mealId);
    final controller = Get.find<RecipePageController>(tag: mealId);
    controller.initialize(mealId, mealName);

    return Scaffold(
      appBar: AppBar(
        title: Text(mealName),
        actions: [
          Obx(() {
            if (controller.meal.value != null) {
              return IconButton(
                icon: Icon(
                  controller.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: controller.isFavorite ? Colors.red : null,
                ),
                onPressed: controller.toggleFavorite,
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() => _buildBody(controller)),
    );
  }

  /// Builds the body of the page.
  ///
  /// This method returns different widgets based on the current state:
  /// - A loading indicator if the data is being fetched.
  /// - An error view if an error occurred during the fetch.
  /// - A message indicating no meal details are available if the meal is null.
  /// - The meal details if the meal is successfully fetched.
  Widget _buildBody(RecipePageController controller) {
    if (controller.isLoading.value) {
      return const LoadingView();
    }

    if (controller.error.value != null) {
      return ErrorView(
        onRetry: controller.loadMealDetails,
        errString: controller.error.value!,
      );
    }

    if (controller.meal.value == null) {
      return const Center(child: Text(TextConstants.noMealDetailsError));
    }

    final meal = controller.meal.value!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.doublePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecipeHeader(
            mealId: meal.idMeal,
            imageUrl: meal.strMealThumb,
            ingredientsSection: RecipeIngredientsSection(
              ingredients: meal.ingredients,
              measures: meal.measures,
            ),
          ),
          const SizedBox(height: UIConstants.defaultSpacing),
          RecipeInstructionsSection(
            instructions: meal.strInstructions,
          ),
          const SizedBox(height: UIConstants.defaultSpacing),
          RecipeMetadataSection(
            category: meal.strCategory,
            area: meal.strArea,
          ),
        ],
      ),
    );
  }
}
