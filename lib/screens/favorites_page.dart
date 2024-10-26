import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../screens/recipe_page.dart';
import '../services/favorites_service.dart';
import '../widgets/common/meal_image.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Meal> favoriteMeals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => isLoading = true);
    final meals = await _favoritesService.getFavorites();
    setState(() {
      favoriteMeals = meals;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteMeals.isEmpty
              ? const Center(child: Text('No favorite recipes yet'))
              : ListView.builder(
                  itemCount: favoriteMeals.length,
                  itemBuilder: (context, index) {
                    final meal = favoriteMeals[index];
                    return ListTile(
                      title: Text(meal.strMeal),
                      leading: MealImage(
                        mealId: meal.idMeal,
                        imageUrl: meal.strMealThumb,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetail(
                              mealName: meal.strMeal,
                              mealId: meal.idMeal,
                            ),
                          ),
                        ).then((_) => _loadFavorites());
                      },
                    );
                  },
                ),
    );
  }
}
