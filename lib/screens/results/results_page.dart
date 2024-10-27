/// A stateful widget that displays search results or meals by category.
///
/// The [ResultsPage] widget fetches and displays a list of meals based on the
/// provided search query or category name. It supports pagination and handles
/// loading states and errors.
///
/// The widget requires either a [searchQuery] or a [categoryName] to be provided.
///
/// The [searchByName] and [searchByIngredient] flags determine the type of search
/// to be performed when a [searchQuery] is provided.
///
/// The [ResultsPage] consists of the following main components:
/// - An app bar displaying the search query or category name.
/// - A body that displays a loading indicator, error message, or the list of meals.
///
/// The meals are fetched using the [ApiService] and displayed in batches for
/// better performance and user experience.
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
import '../../models/meal_model.dart';
import '../../widgets/error/error_view.dart';
import '../../widgets/loading/loading_view.dart';
import '../recipe/recipe_page.dart';
import 'widgets/paginated_results.dart';

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

  // List to store all fetched meals
  List<dynamic> _allMeals = [];

  // List to store meals currently displayed on the screen
  final List<dynamic> _displayedMeals = [];

  // Flags to handle loading states
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  String? _error;

  // Number of meals to load per batch
  static const int _batchSize = 10;

  @override
  void initState() {
    super.initState();
    // Add scroll listener to handle pagination
    _scrollController.addListener(_onScroll);
    _loadInitialResults();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handles scroll events to implement pagination. This method checks if the
  /// user has scrolled to 90% of the maximum scroll extent and if more data
  /// can be loaded.
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadNextBatch();
    }
  }

  // Method to load the initial set of results based on search query or category
  Future<void> _loadInitialResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    ApiResponse<List<dynamic>> response;

    if (widget.searchQuery != null) {
      // Handle search
      response = await _apiService.searchMeals(
        query: widget.searchQuery!,
        searchByName: widget.searchByName,
        searchByIngredient: widget.searchByIngredient,
      );
    } else if (widget.categoryName != null) {
      // Handle category selection
      response = await _apiService.getMealsByCategory(widget.categoryName!);
    } else {
      throw Exception(
          'Either searchQuery or categoryName must be provided'); // This should never happen, but just in case
    }

    if (response.error != null) {
      setState(() {
        _error = TextConstants.loadError;
        _isLoading = false;
      });
      return;
    }

    _allMeals = response.data ?? [];
    _loadNextBatch();

    setState(() {
      _isLoading = false;
      _hasMore = _displayedMeals.length < _allMeals.length;
    });
  }

  // Method to load the next batch of results for pagination
  void _loadNextBatch() {
    if (!_hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    final currentLength = _displayedMeals.length;
    final nextBatch = _allMeals.skip(currentLength).take(_batchSize).toList();

    setState(() {
      _displayedMeals.addAll(nextBatch);
      _hasMore = _displayedMeals.length < _allMeals.length;
      _isLoadingMore = false;
    });
  }

  // Method to navigate to the detailed recipe page
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

  // Method to get the title of the page based on search query or category
  String _getPageTitle() {
    if (widget.searchQuery != null) {
      return '${TextConstants.searchResultsTitle}: ${widget.searchQuery}';
    } else if (widget.categoryName != null) {
      return '${TextConstants.categoryLabel}: ${widget.categoryName}';
    }
    return TextConstants.genericResultsTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
      ),
      body: _buildBody(),
    );
  }

  // Method to build the body of the page based on loading state, errors, and results
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView();
    }

    if (_error != null) {
      return ErrorView(onRetry: _loadInitialResults, errString: _error!);
    }

    if (_displayedMeals.isEmpty) {
      return const ErrorView(errString: TextConstants.noResultsError);
    }

    return PaginatedResults(
      displayedMeals: _displayedMeals,
      onMealSelected: _navigateToRecipe,
      scrollController: _scrollController,
      isLoadingMore: _isLoadingMore,
      hasMore: _hasMore,
    );
  }
}
