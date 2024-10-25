import 'package:flutter/material.dart';
import '../screens/recipe_page.dart';

class RecipeList extends StatelessWidget {
  final List<dynamic> meals;

  RecipeList({required this.meals});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return ListTile(
          title: Text(meal['strMeal']),
          leading: Image.network(meal['strMealThumb']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetail(mealName: meal["strMeal"]),
              ),
            );
          },
        );
      },
    );
  }
}
