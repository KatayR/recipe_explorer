import 'package:flutter/material.dart';
import 'package:recipe_explorer/widgets/loading/loading_view.dart';
import '../../../services/favorites_service.dart';
import '../../models/meal_model.dart';
import '../../widgets/meal/meal_grid.dart';
import '../recipe/recipe_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Meal> _favoriteMeals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    final meals = await _favoritesService.getFavorites();

    setState(() {
      _favoriteMeals = meals;
      _isLoading = false;
    });
  }

  void _onMealSelected(Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipePage(
          mealId: meal.idMeal,
          mealName: meal.strMeal,
        ),
      ),
    ).then((_) => _loadFavorites()); // Refresh list when returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView();
    }

    if (_favoriteMeals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No favorite recipes yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add some recipes to your favorites!',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Convert Meal objects to map format expected by MealGrid
    final mealsData = _favoriteMeals.map((meal) => meal.toJson()).toList();

    return MealGrid(
      meals: mealsData,
      onMealSelected: _onMealSelected,
      // No need for pagination here as favorites are usually fewer
    );
  }
}
