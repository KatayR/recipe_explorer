import 'package:flutter/material.dart';
import 'package:recipe_explorer/widgets/error/error_view.dart';
import '../../../services/api_service.dart';
import '../../../services/favorites_service.dart';
import '../../models/meal_model.dart';
import '../../widgets/loading/loading_view.dart';
import 'widgets/instructions.dart';
import 'widgets/header.dart';
import 'widgets/ingredients.dart';
import 'widgets/metadata.dart';

class RecipePage extends StatefulWidget {
  final String mealId;
  final String mealName;

  const RecipePage({
    super.key,
    required this.mealId,
    required this.mealName,
  });

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final ApiService _apiService = ApiService();
  final FavoritesService _favoritesService = FavoritesService();

  Meal? _meal;
  bool _isLoading = true;
  bool _isFavorite = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMealDetails();
  }

  /// Loads the details of the meal.
  ///
  /// This method first checks if the meal is saved as a favorite. If it is,
  /// it loads the saved details. Otherwise, it fetches the meal details from
  /// the API. If an error occurs during the fetch, an error message is displayed.
  Future<void> _loadMealDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final savedMeal = await _favoritesService.loadMealIfSaved(widget.mealId);
    if (savedMeal != null) {
      setState(() {
        _meal = savedMeal;
        _isFavorite = true;
        _isLoading = false;
      });
      return;
    }

    final response = await _apiService.searchMealsByName(widget.mealName);
    setState(() {
      _isLoading = false;
      if (response.error != null) {
        _error =
            'Unable to load recipe. Please check your internet connection.';
      } else if (response.data != null && response.data!.isNotEmpty) {
        _meal = Meal.fromJson(response.data!.first);
      } else {
        _error = 'Meal not found';
      }
    });
  }

  /// Toggles the favorite status of the meal.
  ///
  /// This method updates the favorite status of the meal by calling the
  /// [FavoritesService]. If the meal is marked as a favorite, it is saved;
  /// otherwise, it is removed from the favorites.
  Future<void> _toggleFavorite() async {
    if (_meal == null) return;
    final newStatus = await _favoritesService.toggleFavorite(_meal!);
    setState(() => _isFavorite = newStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealName),
        actions: [
          if (_meal != null)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Builds the body of the page.
  ///
  /// This method returns different widgets based on the current state:
  /// - A loading indicator if the data is being fetched.
  /// - An error view if an error occurred during the fetch.
  /// - A message indicating no meal details are available if the meal is null.
  /// - The meal details if the meal is successfully fetched.
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView();
    }

    if (_error != null) {
      return ErrorView(onRetry: _loadMealDetails, errString: _error!);
    }

    if (_meal == null) {
      return const Center(child: Text('No meal details available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 16),
          RecipeInstructionsSection(
            instructions: _meal!.strInstructions,
          ),
          const SizedBox(height: 16),
          RecipeMetadataSection(
            category: _meal!.strCategory,
            area: _meal!.strArea,
          ),
        ],
      ),
    );
  }
}
