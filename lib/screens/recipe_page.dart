import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/favorites_service.dart';
import '../../utils/responsive_helper.dart';
import '../models/meal_model.dart';
import '../widgets/common/meal_image.dart';

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
    setState(() => _isLoading = true);

    // First check if meal is in favorites
    final savedMeal = await _favoritesService.loadMealIfSaved(widget.mealId);
    if (savedMeal != null) {
      setState(() {
        _meal = savedMeal;
        _isFavorite = true;
        _isLoading = false;
      });
      return;
    }

    // If not in favorites, fetch from API
    final response = await _apiService.searchMealsByName(widget.mealName);

    setState(() {
      _isLoading = false;
      if (response.error != null) {
        _error = response.error;
      } else if (response.data != null && response.data!.isNotEmpty) {
        _meal = Meal.fromJson(response.data!.first);
      } else {
        _error = 'Meal not found';
      }
    });
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
            Text(_error!),
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
          // Recipe Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: MealImage(
              mealId: _meal!.idMeal,
              imageUrl: _meal!.strMealThumb,
              height: ResponsiveHelper.isMobile(context) ? 200 : 400,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),

          // Ingredients Section
          _buildIngredients(),
          const SizedBox(height: 16),

          // Instructions Section
          _buildInstructions(),
          const SizedBox(height: 16),

          // Additional Info
          _buildMetadata(),
        ],
      ),
    );
  }

  Widget _buildIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          _meal!.ingredients.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '• ${_meal!.ingredients[index]} - ${_meal!.measures[index]}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instructions:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _meal!.strInstructions,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category: ${_meal!.strCategory}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Cuisine: ${_meal!.strArea}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
