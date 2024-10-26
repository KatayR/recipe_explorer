import 'package:flutter/material.dart';
import 'screens/home/home_page.dart';

void main() {
  runApp(const RecipeExplorer());
}

class RecipeExplorer extends StatelessWidget {
  const RecipeExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
