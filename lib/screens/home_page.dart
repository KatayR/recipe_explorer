import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../screens/favorites_page.dart';
import '../screens/recipe_page.dart';
import '../screens/results_page.dart';
import '../services/meals_service.dart';
import '../widgets/home/categories.dart';
import '../widgets/home/custom_search_bar.dart';
import '../widgets/meal_list/meal_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MealService _mealService = MealService();
  List<Category> _categories = [];
  bool _showSearch = false;

  void _searchMeals(String query, SearchOptions searchOptions) {
    if (query.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            searchQuery: query,
            searchOptions: searchOptions,
          ),
        ),
      );
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _mealService.getCategories();
      setState(() {
        _categories =
            categories.map((json) => Category.fromJson(json)).toList();
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  void _onCategorySelected(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          categoryName: category,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
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
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoritesPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchBar(
            isVisible: _showSearch,
            onSearch: _searchMeals,
            onClose: () => setState(() => _showSearch = false),
          ),
          CategoryList(
            categories: _categories,
            onCategorySelected: _onCategorySelected,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Sample dishes you can make with chicken"),
          ),
          Expanded(
            child: FutureBuilder<MealResponse>(
              future: _mealService.fetchMeals(category: 'Chicken'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading default(chicken) recipes'),
                  );
                }
                return MealGrid(
                  meals: snapshot.data?.meals ?? [],
                  onMealSelected: (meal) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetail(
                            mealName: meal.strMeal, mealId: meal.idMeal),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
