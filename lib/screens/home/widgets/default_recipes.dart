/// A widget that displays a section of default recipes fetched from an API.
///
/// The `DefaultRecipesSection` widget is a stateless widget that fetches and displays
/// a list of sample dishes that can be made with chicken. It uses the `ApiService`
/// to fetch the data and displays it in a grid format. If there is an error during
/// the fetch operation or if the data is still loading, appropriate views are shown.
///
/// This widget requires an instance of `ApiService` to be passed as a required parameter.
///
/// Example usage:
/// ```dart
/// DefaultRecipesSection(apiService: myApiServiceInstance);
/// ```
///
/// The widget consists of:
/// - A title indicating the type of dishes being displayed.
/// - A `FutureBuilder` that handles the asynchronous fetching of data.
/// - A `LoadingView` that is displayed while the data is being fetched.
/// - An `ErrorView` that is displayed if there is an error during the fetch operation.
/// - A `MealGrid` that displays the fetched meals in a grid format.
///
/// When a meal is selected from the grid, the user is navigated to the `RecipePage`
/// for that specific meal.

import 'package:flutter/material.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import 'package:recipe_explorer/constants/ui_constants.dart';
import '../../../services/api_service.dart';
import '../../../services/image_preloader.dart';
import '../../../widgets/loading/loading_view.dart';
import '../../../widgets/meal/meal_grid.dart';
import '../../../widgets/scroll/scrollable_wrapper.dart';
import '../../recipe/recipe_page.dart';

class DefaultRecipesSection extends StatefulWidget {
  final ApiService apiService;

  const DefaultRecipesSection({
    super.key,
    required this.apiService,
  });

  @override
  State<DefaultRecipesSection> createState() => _DefaultRecipesSectionState();
}

class _DefaultRecipesSectionState extends State<DefaultRecipesSection> {
  ScrollController? _scrollController;
  final ImagePreloaderService _imagePreloader = ImagePreloaderService();
  List<dynamic> _meals = [];
  bool _imagesPreloaded = false;
  int _preloadedCount = 0;
  bool _isPreloading = false;

  @override
  void initState() {
    super.initState();
    _loadMealsAndPreloadImages();
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController == null || _meals.isEmpty || _isPreloading) return;
    
    // Step 1: Get raw scroll data in pixels
    final scrollOffset = _scrollController!.offset; // Current scroll position from top
    final maxScrollExtent = _scrollController!.position.maxScrollExtent; // Total scrollable distance
    
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

  // Removed _getGridColumns() - no longer needed since we're not using fixed height calculations

  Future<void> _loadMealsAndPreloadImages() async {
    try {
      final response = await widget.apiService.getMealsByCategory('Chicken');
      if (response.data != null && mounted) {
        setState(() {
          _meals = response.data!;
        });
        
        _preloadFirstBatch();
      }
    } catch (e) {
      debugPrint('Error loading meals: $e');
    }
  }

  void _preloadFirstBatch() async {
    if (_meals.isNotEmpty && !_imagesPreloaded && mounted) {
      // Initial preload: Use standard count for consistency
      final imagesToPreload = _meals
          .take(ImagePreloaderService.standardPreloadCount)
          .map((meal) => meal['strMealThumb'] as String)
          .where((url) => url.isNotEmpty)
          .toList();
      
      debugPrint('Found ${imagesToPreload.length} images to preload');
      debugPrint('Image URLs: ${imagesToPreload.join(', ')}');
      
      if (imagesToPreload.isNotEmpty && mounted) {
        debugPrint('Starting image preloading...');
        await _imagePreloader.preloadNetworkImages(imagesToPreload, context);
        debugPrint('Image preloading completed');
        
        if (mounted) {
          setState(() {
            _imagesPreloaded = true;
            _preloadedCount = ImagePreloaderService.standardPreloadCount;
          });
          debugPrint('Home: Initial preload completed - ${_preloadedCount} images cached');
          
          // Set up scroll listener for progressive preloading
          _scrollController?.addListener(_onScroll);
        }
      }
    }
  }


  void _preloadMoreImages(int targetCount) async {
    if (targetCount <= _preloadedCount || !mounted || _isPreloading) return;
    
    _isPreloading = true;
    
    // Get the next batch of images to preload
    final newImagesToPreload = _meals
        .skip(_preloadedCount)
        .take(targetCount - _preloadedCount)
        .map((meal) => meal['strMealThumb'] as String)
        .where((url) => url.isNotEmpty)
        .toList();
    
    if (newImagesToPreload.isNotEmpty) {
      debugPrint('Home Progressive: Preloading ${newImagesToPreload.length} more images (${_preloadedCount + 1} to $targetCount) for smooth scrolling');
      
      await _imagePreloader.preloadNetworkImages(newImagesToPreload, context);
      
      if (mounted) {
        _preloadedCount = targetCount;
        debugPrint('Home Progressive: Now have $_preloadedCount/${_meals.length} images preloaded');
      }
    }
    
    _isPreloading = false;
  }
  @override
  Widget build(BuildContext context) {
    // Get the primary scroll controller which is set by NestedScrollView
    _scrollController = PrimaryScrollController.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(UIConstants.defaultPadding),
          child: Text(
            TextConstants.defaultCategoryTitle,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _meals.isEmpty
              ? const LoadingView()
              : ScrollableWrapper(
                  controller: _scrollController,
                  useScaffold: false,
                  child: MealGrid(
                    meals: _meals,
                    onMealSelected: (meal) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipePage(
                          mealId: meal.idMeal,
                          mealName: meal.strMeal,
                        ),
                      ),
                    ),
                    scrollController: _scrollController,
                  ),
                ),
        ),
      ],
    );
  }
}
