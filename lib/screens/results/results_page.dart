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
import '../../../services/scroll_preloader.dart';
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
  ScrollPreloader? _scrollPreloader;
  List<dynamic> _meals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  @override
  void dispose() {
    _scrollPreloader?.dispose();
    _scrollController.dispose();
    super.dispose();
  }


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
      
      // Initialize preloading after meals are loaded
      if (_meals.isNotEmpty) {
        await _initializePreloading();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = TextConstants.loadError;
      });
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
    _scrollController.addListener(() {
      _scrollPreloader!.onScroll(_scrollController);
    });
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
