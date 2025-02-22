import 'package:flutter/material.dart';
import 'package:recipe_explorer/widgets/connectivity/connected_wrapper.dart';
import '../../../services/api_service.dart';
import '../../constants/text_constants.dart';
import '../../constants/ui_constants.dart';
import '../../widgets/error/error_view.dart';
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

  @override
  void initState() {
    super.initState();
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
      body: SafeArea(
        child: ConnectivityWrapper(
          errorBuilder: (retryCallback) => CustomScrollView(
            slivers: [
              const HomeAppBar(),
              SliverFillRemaining(
                child: Center(
                  child: ErrorView(
                    errString: TextConstants.loadError,
                    onRetry: retryCallback,
                  ),
                ),
              ),
            ],
          ),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              const HomeAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.defaultPadding),
                      child: CustomSearchBar(onSearch: _searchMeals),
                    ),
                    CategoriesSection(
                      onCategorySelected: _onCategorySelected,
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ],
            body: DefaultRecipesSection(apiService: _apiService),
          ),
        ),
      ),
    );
  }
}
