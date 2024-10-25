import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/meals_service.dart';
import '../widgets/categories_list.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/recipes_list.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  MealService _mealService = MealService();
  List<dynamic> _searchResults = [];
  List<Category> _categories = [];

  void _searchMeals() async {
    final results =
        await _mealService.searchMealsByName(_searchController.text);
    setState(() {
      _searchResults = results;
    });
  }

  void _loadCategories() async {
    final categories = await _mealService.getCategories();
    setState(() {
      _categories = categories.map((json) => Category.fromJson(json)).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _onCategorySelected(String category) async {
    final meals = await _mealService.getMealsByCategory(category);
    setState(() {
      _searchResults = meals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipi Explorer'),
      ),
      body: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            onSearch: _searchMeals,
          ),
          CategoryList(
            categories: _categories,
            onCategorySelected: _onCategorySelected,
          ),
          _searchResults.isNotEmpty
              ? Expanded(child: RecipeList(meals: _searchResults))
              : Center(child: Text('No results found')),
        ],
      ),
    );
  }
}
