/// A stateful widget that displays the user's favorite recipes.
///
/// The `FavoritesPage` widget fetches and displays a list of favorite meals
/// from the `FavoritesService`. It shows a loading indicator while the data
/// is being fetched and displays a message if no favorite recipes are found.
///
/// When a meal is selected, it navigates to the `RecipePage` to show the
/// details of the selected meal. Upon returning from the `RecipePage`, the
/// list of favorite meals is refreshed.
///
/// The widget consists of:
/// - An `AppBar` with the title "Favorite Recipes".
/// - A body that shows either a loading indicator, a message indicating no
///   favorite recipes, or a grid of favorite meals.
///
/// The favorite meals are displayed using the `MealGrid` widget, which
/// expects the meals data in a map format.
import 'package:flutter/material.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import 'package:recipe_explorer/constants/ui_constants.dart';
import 'package:recipe_explorer/widgets/loading/loading_view.dart';
import '../../../services/favorites_service.dart';
import '../../../services/scroll_preloader.dart';
import '../../models/meal_model.dart';
import '../../widgets/meal/meal_grid.dart';
import '../../widgets/scroll/scrollable_wrapper.dart';
import '../recipe/recipe_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favoritesService = FavoritesService();
  final ScrollController _scrollController = ScrollController();
  ScrollPreloader? _scrollPreloader;
  List<Meal> _favoriteMeals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _scrollPreloader?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final meals = await _favoritesService.getFavorites();
    setState(() {
      _favoriteMeals = meals;
      _isLoading = false;
    });
    
    // Initialize preloading after favorites are loaded
    if (_favoriteMeals.isNotEmpty) {
      await _initializePreloading();
    }
  }

  Future<void> _initializePreloading() async {
    if (_favoriteMeals.isEmpty) return;

    // Extract image URLs from favorite meals
    final imageUrls = _favoriteMeals
        .map((meal) => meal.strMealThumb)
        .where((url) => url.isNotEmpty)
        .toList();

    // Initialize scroll preloader service
    _scrollPreloader = ScrollPreloader(imageUrls: imageUrls);
    await _scrollPreloader!.initialize(context);

    // Set up scroll listener to delegate to the service
    _scrollController.addListener(() {
      _scrollPreloader!.onScroll(_scrollController);
    });
  }

  void _onMealSelected(Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipePage(
          mealId: meal.idMeal,
          mealName: meal.strMeal,
        ),
      ),
    ).then((_) => _loadFavorites()); // Refreshing list when returning
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingView();
    }

    if (_favoriteMeals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: UIConstants.defaultSpacing),
            Text(
              TextConstants.noFavoritesMessage,
              style: TextStyle(
                fontSize: UIConstants.bodyFontSize,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: UIConstants.defaultPadding),
            Text(
              TextConstants.addFavoritesMessage,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final mealsData = _favoriteMeals.map((meal) => meal.toJson()).toList();

    return MealGrid(
      meals: mealsData,
      onMealSelected: _onMealSelected,
      scrollController: _scrollController,
      useCachedImages: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableWrapper(
      controller: _scrollController,
      title: TextConstants.favoritesTitle,
      child: _buildContent(),
    );
  }
}
