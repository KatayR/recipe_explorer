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
  final TextEditingController _searchController = TextEditingController();
  final MealService _mealService = MealService();
  List<Category> _categories = [];

  void _searchMeals() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            searchQuery: query,
          ),
        ),
      );
    }
  }

  void _loadCategories() async {
    final categories = await _mealService.getCategories();
    setState(() {
      _categories = categories.map((json) => Category.fromJson(json)).toList();
    });
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
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage()),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Favorites'),
                  SizedBox(width: 8),
                  Icon(Icons.favorite),
                ],
              ),
            ),
          ],
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Some chicken recipes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                        child: Text('Error loading default(chicken) recipes'));
                  }
                  return MealGrid(
                    meals: snapshot.data?.meals ?? [],
                    onMealSelected: (mealName) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetail(mealName: mealName),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ));
  }
}
