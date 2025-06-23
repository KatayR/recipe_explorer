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
import '../../../services/image_preloader.dart';
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
  final ImagePreloaderService _imagePreloader = ImagePreloaderService();
  List<Meal> _favoriteMeals = [];
  bool _isLoading = true;
  bool _imagesPreloaded = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
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
    
    // Preload images after favorites are loaded
    if (_favoriteMeals.isNotEmpty) {
      _preloadImages();
    }
  }

  void _preloadImages() async {
    if (_favoriteMeals.isNotEmpty && !_imagesPreloaded && mounted) {
      // Use standard preload count for consistency
      final imagesToPreload = _favoriteMeals
          .take(ImagePreloaderService.standardPreloadCount)
          .map((meal) => meal.strMealThumb)
          .where((url) => url.isNotEmpty)
          .toList();
      
      debugPrint('Favorites: Found ${imagesToPreload.length}/${_favoriteMeals.length} images to preload');
      
      if (imagesToPreload.isNotEmpty && mounted) {
        debugPrint('Favorites: Starting image preloading...');
        await _imagePreloader.preloadNetworkImages(imagesToPreload, context);
        debugPrint('Favorites: Image preloading completed');
        
        if (mounted) {
          setState(() {
            _imagesPreloaded = true;
          });
          debugPrint('Favorites: Initial preload completed - ${imagesToPreload.length} images cached');
        }
      }
    }
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
