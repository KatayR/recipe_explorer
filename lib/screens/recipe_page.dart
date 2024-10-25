import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/meals_service.dart';
import '../services/favorites_service.dart';

class RecipeDetail extends StatefulWidget {
  final String mealName;

  const RecipeDetail({super.key, required this.mealName});

  @override
  RecipeDetailState createState() => RecipeDetailState();
}

class RecipeDetailState extends State<RecipeDetail> {
  final FavoritesService _favoritesService = FavoritesService();
  final MealService _mealService = MealService();

  Meal? meal;
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadMealDetails();
  }

  Future<void> _loadMealDetails() async {
    final result = await _mealService.searchMealsByName(widget.mealName);

    if (result.isNotEmpty) {
      final mealData = result.first;
      final loadedMeal = Meal.fromJson(mealData);
      final favoriteStatus =
          await _favoritesService.isFavorite(loadedMeal.idMeal);

      setState(() {
        meal = loadedMeal;
        isFavorite = favoriteStatus;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (meal == null) return;

    await _favoritesService.toggleFavorite(meal!.toJson());

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealName),
        actions: [
          if (meal != null)
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (meal == null) {
      return const Center(child: Text('No meal found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildIngredients(),
          const SizedBox(height: 16),
          _buildInstructions(),
          const SizedBox(height: 16),
          _buildMetadata(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        meal!.strMealThumb,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
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
          meal!.ingredients.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '• ${meal!.ingredients[index]} - ${meal!.measures[index]}',
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
          meal!.strInstructions,
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
          'Category: ${meal!.strCategory}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Cuisine: ${meal!.strArea}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
