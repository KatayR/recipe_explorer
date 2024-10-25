import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../screens/recipe_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Meal> favoriteMeals = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      favoriteMeals =
          favorites.map((item) => Meal.fromJson(jsonDecode(item))).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Recipes'),
      ),
      body: favoriteMeals.isEmpty
          ? Center(child: Text('No favorite recipes yet'))
          : ListView.builder(
              itemCount: favoriteMeals.length,
              itemBuilder: (context, index) {
                final meal = favoriteMeals[index];
                return ListTile(
                  title: Text(meal.strMeal),
                  leading: Image.network(meal.strMealThumb),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeDetail(mealName: meal.strMeal),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
