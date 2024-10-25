import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../screens/favorites_page.dart';
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
  Future<List<dynamic>>? _chickenRecipesFuture;

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

  Future<List<dynamic>> _loadChickenRecipes() async {
    final chickenRecipes = await _mealService.getMealsByCategory('Chicken');
    return chickenRecipes;
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _chickenRecipesFuture = _loadChickenRecipes();
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
      appBar: AppBar(title: Text('Recipe Explorer'), actions: [
        IconButton(
          icon: Icon(Icons.favorite),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoritesPage()),
            );
          },
        ),
      ]),
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
              : Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Tavuk ile yapabileceğiniz örnek yemekler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<List<dynamic>>(
                          future: _chickenRecipesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text(
                                      'Error loading default (chicken) recipes'));
                            } else if (snapshot.hasData &&
                                snapshot.data!.isNotEmpty) {
                              return RecipeList(meals: snapshot.data!);
                            } else {
                              return Center(
                                  child: Text('No chicken recipes available'));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
