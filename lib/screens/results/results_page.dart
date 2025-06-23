/// A stateful widget that displays search results or meals by category.
///
/// The [ResultsPage] widget fetches and displays a list of meals based on the
/// provided search query or category name.
/// The widget requires either a [searchQuery] or a [categoryName] to be provided.
///
/// The [searchByName] and [searchByIngredient] flags determine the type of search
/// to be performed when a [searchQuery] is provided.
///
/// The [ResultsPage] consists of the following main components:
/// - An app bar displaying the search query or category name.
/// - A body that displays a loading indicator, error message, or the list of meals.
///
/// The meals are fetched using the [ApiService].
///
/// The widget also supports navigation to a detailed recipe page when a meal is
/// selected.
///
/// Example usage:
///
/// ```dart
/// ResultsPage(
///   searchQuery: 'Chicken',
///   searchByName: true,
///   searchByIngredient: false,
/// );
/// ```
///
/// or
///
/// ```dart
/// ResultsPage(
///   categoryName: 'Dessert',
/// );
/// ```
import 'package:flutter/material.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import '../../../services/api_service.dart';
import '../../../services/image_preloader.dart';
import '../../models/meal_model.dart';
import '../../widgets/error/error_view.dart';
import '../../widgets/loading/loading_view.dart';
import '../../widgets/meal/meal_grid.dart';
import '../../widgets/scroll/scrollable_wrapper.dart';
import '../recipe/recipe_page.dart';

class ResultsPage extends StatefulWidget {
  final String? searchQuery;
  final String? categoryName;
  final bool searchByName;
  final bool searchByIngredient;

  const ResultsPage({
    super.key,
    this.searchQuery,
    this.categoryName,
    this.searchByName = true,
    this.searchByIngredient = false,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final ImagePreloaderService _imagePreloader = ImagePreloaderService();
  List<dynamic> _meals = [];
  bool _isLoading = true;
  String? _error;
  bool _imagesPreloaded = false;
  int _preloadedCount = 0;
  bool _isPreloading = false;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_meals.isEmpty || _isPreloading) return;
    
    // Step 1: Get raw scroll data in pixels
    final scrollOffset = _scrollController.offset; // Current scroll position from top
    final maxScrollExtent = _scrollController.position.maxScrollExtent; // Total scrollable distance
    
    // Step 2: Convert pixels to percentage (0.0 = top, 1.0 = bottom)
    final scrollPercentage = maxScrollExtent > 0 ? scrollOffset / maxScrollExtent : 0.0;
    
    // Step 3: Map scroll percentage to approximate item index user is viewing
    // Example: 50% scroll in 36-item list = viewing item 18
    final currentItemIndex = (scrollPercentage * _meals.length).floor();
    
    // Step 4: Calculate target to stay 20 items ahead
    // Example: viewing item 10 → preload up to item 30
    final targetPreloadCount = (currentItemIndex + 20).clamp(0, _meals.length);
    
    // Step 5: Enforce minimum 15 items for early scrolling in long lists
    // Example: viewing item 0 in 100-item list → ensure we preload at least 15, not just 20
    final proposedTarget = targetPreloadCount < ImagePreloaderService.standardPreloadCount 
        ? ImagePreloaderService.standardPreloadCount 
        : targetPreloadCount;
    
    // Step 6: End-of-list optimization - if we'd leave ≤5 items, just preload everything
    final currentRemaining = _meals.length - _preloadedCount; // Items not yet preloaded
    final remainingAfterProposed = _meals.length - proposedTarget; // Items that would remain after proposed target
    final shouldPreloadAll = currentRemaining <= 5 || remainingAfterProposed <= 5;
    
    // Step 7: Trigger preloading with spam prevention
    if (shouldPreloadAll && currentRemaining > 0) {
      _preloadMoreImages(_meals.length); // Preload all remaining items
    } else if (proposedTarget > _preloadedCount + 5) {
      _preloadMoreImages(proposedTarget); // Only trigger if we need ≥5 more items
    }
  }

  // Removed _getGridColumns() - using scroll percentage instead of fixed height calculations

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = widget.searchQuery != null
          ? await _apiService.searchMeals(
              query: widget.searchQuery!,
              searchByName: widget.searchByName,
              searchByIngredient: widget.searchByIngredient,
            )
          : await _apiService.getMealsByCategory(widget.categoryName!);

      setState(() {
        _isLoading = false;
        if (response.error != null) {
          _error = TextConstants.loadError;
        } else {
          _meals = response.data ?? [];
        }
      });
      
      // Preload images after meals are loaded
      if (_meals.isNotEmpty) {
        _preloadImages();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = TextConstants.loadError;
      });
    }
  }

  void _preloadImages() async {
    if (_meals.isNotEmpty && !_imagesPreloaded && mounted) {
      // Initial preload: Use standard count for consistency across all screens
      final imagesToPreload = _meals
          .take(ImagePreloaderService.standardPreloadCount)
          .map((meal) => meal['strMealThumb'] as String)
          .where((url) => url.isNotEmpty)
          .toList();
      
      debugPrint('Results: Found ${imagesToPreload.length} images to preload');
      
      if (imagesToPreload.isNotEmpty && mounted) {
        debugPrint('Results: Starting image preloading...');
        await _imagePreloader.preloadNetworkImages(imagesToPreload, context);
        debugPrint('Results: Image preloading completed');
        
        if (mounted) {
          setState(() {
            _imagesPreloaded = true;
            _preloadedCount = ImagePreloaderService.standardPreloadCount;
          });
          debugPrint('Results: Initial preload completed - ${_preloadedCount} images cached');
          
          // Set up scroll listener for progressive preloading
          _scrollController.addListener(_onScroll);
        }
      }
    }
  }

  void _preloadMoreImages(int targetCount) async {
    if (targetCount <= _preloadedCount || !mounted || _isPreloading) return;
    
    _isPreloading = true;
    
    // Get next batch of images to preload
    final newImagesToPreload = _meals
        .skip(_preloadedCount)
        .take(targetCount - _preloadedCount)
        .map((meal) => meal['strMealThumb'] as String)
        .where((url) => url.isNotEmpty)
        .toList();
    
    if (newImagesToPreload.isNotEmpty) {
      debugPrint('Results Progressive: Preloading ${newImagesToPreload.length} more images (${_preloadedCount + 1} to $targetCount) for smooth scrolling');
      
      await _imagePreloader.preloadNetworkImages(newImagesToPreload, context);
      
      if (mounted) {
        _preloadedCount = targetCount;
        debugPrint('Results Progressive: Now have $_preloadedCount/${_meals.length} images preloaded');
      }
    }
    
    _isPreloading = false;
  }

  void _navigateToRecipe(Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipePage(
          mealId: meal.idMeal,
          mealName: meal.strMeal,
        ),
      ),
    );
  }

  String _getPageTitle() {
    if (widget.searchQuery != null) {
      return '${TextConstants.searchResultsTitle}: ${widget.searchQuery}';
    } else if (widget.categoryName != null) {
      return '${TextConstants.categoryResultsTitle}: ${widget.categoryName}';
    }
    return TextConstants.genericResultsTitle;
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingView();
    }

    if (_error != null) {
      return ErrorView(
        onRetry: _loadResults,
        errString: _error!,
      );
    }

    if (_meals.isEmpty) {
      return const ErrorView(
        errString: TextConstants.noResultsError,
      );
    }

    return MealGrid(
      meals: _meals,
      onMealSelected: _navigateToRecipe,
      scrollController: _scrollController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableWrapper(
      controller: _scrollController,
      title: _getPageTitle(),
      child: _buildContent(),
    );
  }
}
