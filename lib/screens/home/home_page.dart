import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../models/category_model.dart';
import '../../widgets/loading/loading_view.dart';
import 'widgets/app_bar.dart';
import 'widgets/categories.dart';
import 'widgets/custom_search_bar.dart';
import 'widgets/default_recipes.dart';
import '../results/results_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override

  // If you dont add the following ignore thingy, you will get a false-positive
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
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
      appBar: const HomeAppBar(),
      body: Column(
        children: [
          CustomSearchBar(onSearch: _searchMeals),
          if (_isLoadingCategories) // could use future builder here but too much boilerplate
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LoadingView(),
            )
          else
            CategoryList(
              categories: _categories,
              onCategorySelected: _onCategorySelected,
            ),
          Expanded(
            child: DefaultRecipesSection(apiService: _apiService),
          ),
        ],
      ),
    );
  }
}
