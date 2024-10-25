import 'package:flutter/material.dart';
import '../widgets/recipes_list.dart';
import '../widgets/recipes_list.dart';

class ResultsPage extends StatelessWidget {
  final List<dynamic> meals;
  final String title;

  const ResultsPage({
    required this.meals,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: meals.isEmpty
          ? Center(child: Text('No recipes found'))
          : RecipeList(meals: meals),
    );
  }
}
