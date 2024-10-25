import 'package:flutter/material.dart';
import '/models/meal_model.dart';
import '/services/meals_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeDetail extends StatefulWidget {
  final String mealName;

  RecipeDetail({required this.mealName});

  @override
  _RecipeDetailState createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  Meal? meal;
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchMealDetails();
  }

  Future<void> _fetchMealDetails() async {
    MealService mealService = MealService();
    final result = await mealService.searchMealsByName(widget.mealName);

    if (result.isNotEmpty) {
      setState(() {
        meal = Meal.fromJson(result.first);
        isLoading = false;
      });

      _checkIfFavorite();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkIfFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    if (meal != null) {
      setState(() {
        isFavorite = favorites.contains(meal!.idMeal);
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (meal == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      if (isFavorite) {
        favorites.remove(meal!.idMeal);
      } else {
        favorites.add(meal!.idMeal);
      }
      isFavorite = !isFavorite;
    });

    await prefs.setStringList('favorites', favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealName),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : meal == null
              ? Center(child: Text('No meal found'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(meal!.strMealThumb,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover),
                      const SizedBox(height: 16),
                      const Text('Ingredients:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      for (int i = 0; i < meal!.ingredients.length; i++)
                        Text('${meal!.ingredients[i]} - ${meal!.measures[i]}'),
                      const SizedBox(height: 16),
                      const Text('Instructions:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(meal!.strInstructions),
                      const SizedBox(height: 16),
                      Text('Category: ${meal!.strCategory}'),
                      Text('Cuisine: ${meal!.strArea}'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }
}
