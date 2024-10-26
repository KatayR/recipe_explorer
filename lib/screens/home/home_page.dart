import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../models/category_model.dart';
import 'categories.dart';
import 'custom_search_bar.dart';
import '../../widgets/meal/meal_grid.dart';
import '../favorites/favorites_page.dart';
import '../recipe/recipe_page.dart';
import '../results/results_page.dart';
import '../../../utils/error_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  bool _showSearch = false;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final response = await _apiService.getCategories();
    setState(() {
      _isLoadingCategories = false;
      if (response.data != null) {
        _categories =
            response.data!.map((json) => Category.fromJson(json)).toList();
      }
    });
  }

  void _onCategorySelected(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(categoryName: category),
      ),
    );
  }

  void _searchMeals(String query,
      {bool byName = true, bool byIngredient = false}) {
    if (query.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            searchQuery: query,
            searchByName: byName,
            searchByIngredient: byIngredient,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Explorer'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () => setState(() => _showSearch = !_showSearch),
          ),
          TextButton(
            child: const Text('💕', style: TextStyle(fontSize: 22)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          if (_showSearch)
            CustomSearchBar(
              onSearch: _searchMeals,
              onClose: () => setState(() => _showSearch = false),
            ),

          // Categories
          if (_isLoadingCategories)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )
          else
            CategoryList(
              categories: _categories,
              onCategorySelected: _onCategorySelected,
            ),

          // Default Chicken Recipes Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Sample dishes you can make with chicken"),
          ),

          // Default Recipes Grid
          Expanded(
            child: FutureBuilder<ApiResponse<List<dynamic>>>(
              future: _apiService.getMealsByCategory('Chicken'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || (snapshot.data?.error != null)) {
                  return ErrorHandler.buildErrorWidget(
                      snapshot.data?.error ?? 'Error loading recipes');
                }

                final meals = snapshot.data?.data ?? [];
                return MealGrid(
                  meals: meals,
                  onMealSelected: (meal) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipePage(
                        mealId: meal.idMeal,
                        mealName: meal.strMeal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
