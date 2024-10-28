/// A page that displays the details of a recipe.
///
/// The [RecipePage] is a [ConsumerStatefulWidget] that fetches and displays
/// the details of a meal based on the provided [mealId] and [mealName].
///
/// The page first attempts to load the meal details from the favorites provider.
/// If the meal is not found in the favorites, it fetches the details from an API.
///
/// The page also allows the user to add or remove the meal from their favorites.
///
/// The UI consists of a loading view, an error view, or the meal details
/// including the header, ingredients, instructions, and metadata sections.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/text_constants.dart';
import '../../constants/ui_constants.dart';
import '../../models/meal_model.dart';
import '../../services/api_service.dart';
import '../../services/favorites_provider.dart';
import '../../widgets/error/error_view.dart';
import '../../widgets/loading/loading_view.dart';
import 'widgets/header.dart';
import 'widgets/ingredients.dart';
import 'widgets/instructions.dart';
import 'widgets/metadata.dart';

class RecipePage extends ConsumerStatefulWidget {
  final String mealId;
  final String mealName;

  const RecipePage({
    super.key,
    required this.mealId,
    required this.mealName,
  });

  @override
  ConsumerState<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends ConsumerState<RecipePage> {
  final ApiService _apiService = ApiService();
  Meal? _meal;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMealDetails();
  }

  Future<void> _loadMealDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Try to load from favorites first
    final favoritesState = ref.read(favoriteMealsProvider);
    if (favoritesState is AsyncData && favoritesState.value != null) {
      final savedMeal = favoritesState.value
          ?.where((meal) => meal.idMeal == widget.mealId)
          .firstOrNull;

      if (savedMeal != null) {
        setState(() {
          _meal = savedMeal;
          _isLoading = false;
        });
        return;
      }
    }

    // If not in favorites, load from API
    final response = await _apiService.searchMealsByName(widget.mealName);
    setState(() {
      _isLoading = false;
      if (response.error != null) {
        _error = TextConstants.recipeLoadingError;
      } else if (response.data != null && response.data!.isNotEmpty) {
        _meal = Meal.fromJson(response.data!.first);
      } else {
        _error = 'Meal not found';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch favorites state to automatically rebuild when it changes
    final favoritesState = ref.watch(favoriteMealsProvider);

    // Determine if this meal is in favorites
    final isFavorite = favoritesState.whenOrNull(
          data: (meals) => meals.any((meal) => meal.idMeal == widget.mealId),
        ) ??
        false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealName),
        actions: [
          /// Displays a favorite icon button if `_meal` is not null.
          ///
          /// The icon changes based on the `isFavorite` state:
          /// - If `isFavorite` is true, the icon is a filled heart (favorite) with red color.
          /// - If `isFavorite` is false, the icon is an outlined heart (favorite_border).
          ///
          /// When the button is pressed, it toggles the favorite status of `_meal`
          /// by calling `toggleFavorite` on the `favoriteMealsProvider` notifier.
          if (_meal != null)
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () async {
                if (_meal != null) {
                  await ref
                      .read(favoriteMealsProvider.notifier)
                      .toggleFavorite(_meal!);
                }
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView();
    }

    if (_error != null) {
      return ErrorView(
        onRetry: _loadMealDetails,
        errString: _error!,
      );
    }

    if (_meal == null) {
      return const Center(
        child: Text(TextConstants.noMealDetailsError),
      );
    }

    /// Builds a scrollable view containing the recipe details.
    ///
    /// The view includes the following sections:
    /// - A header with the meal image and ingredients.
    /// - Instructions for preparing the meal.
    /// - Metadata about the meal such as category and area.
    ///
    /// The layout is padded and spaced using constants from `UIConstants`.
    ///
    /// Returns a `SingleChildScrollView` widget containing the recipe details.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.doublePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecipeHeader(
            mealId: _meal!.idMeal,
            imageUrl: _meal!.strMealThumb,
            ingredientsSection: RecipeIngredientsSection(
              ingredients: _meal!.ingredients,
              measures: _meal!.measures,
            ),
          ),
          const SizedBox(height: UIConstants.defaultSpacing),
          RecipeInstructionsSection(
            instructions: _meal!.strInstructions,
          ),
          const SizedBox(height: UIConstants.defaultSpacing),
          RecipeMetadataSection(
            category: _meal!.strCategory,
            area: _meal!.strArea,
          ),
        ],
      ),
    );
  }
}
