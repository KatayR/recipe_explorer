import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/favorites_service.dart';
import '../../models/meal_model.dart';
import 'ingredients.dart';
import 'instructions.dart';
import 'widgets/header.dart';
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

  Future<void> _loadMealDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
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
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'An error occurred. Please try again later.';
      });
    }
  }

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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMealDetails,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
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
