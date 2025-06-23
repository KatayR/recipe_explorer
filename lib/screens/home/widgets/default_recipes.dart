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
import '../../../services/scroll_preloader.dart';
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
  ScrollPreloader? _scrollPreloader;
  List<dynamic> _meals = [];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  @override
  void dispose() {
    _scrollPreloader?.dispose();
    super.dispose();
  }

  Future<void> _loadMeals() async {
    try {
      final response = await widget.apiService.getMealsByCategory('Chicken');
      if (response.data != null && mounted) {
        setState(() {
          _meals = response.data!;
        });
        
        await _initializePreloading();
      }
    } catch (e) {
      debugPrint('Error loading meals: $e');
    }
  }

  Future<void> _initializePreloading() async {
    if (_meals.isEmpty) return;

    // Extract image URLs from meals data
    final imageUrls = _meals
        .map((meal) => meal['strMealThumb'] as String)
        .where((url) => url.isNotEmpty)
        .toList();

    // Initialize scroll preloader service
    _scrollPreloader = ScrollPreloader(imageUrls: imageUrls);
    await _scrollPreloader!.initialize(context);

    // Set up scroll listener to delegate to the service
    _scrollController?.addListener(() {
      if (_scrollController != null) {
        _scrollPreloader!.onScroll(_scrollController!);
      }
    });
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
