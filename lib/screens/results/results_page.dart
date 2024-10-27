import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../utils/error_handler.dart';
import '../../widgets/meal/meal_grid.dart';
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

  List<dynamic> _allMeals = [];
  List<dynamic> _displayedMeals = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  static const int _batchSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialResults();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadNextBatch();
    }
  }

  Future<void> _loadInitialResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
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
        throw Exception('Either searchQuery or categoryName must be provided');
      }

      if (response.error != null) {
        setState(() {
          _error = response.error;
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
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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

  String _getPageTitle() {
    if (widget.searchQuery != null) {
      return 'Search Results: ${widget.searchQuery}';
    } else if (widget.categoryName != null) {
      return 'Category: ${widget.categoryName}';
    }
    return 'Results';
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ErrorHandler.buildErrorWidget(
                "Check your connection status and try again"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialResults,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_displayedMeals.isEmpty) {
      return const Center(
        child: Text('No results found'),
      );
    }

    return MealGrid(
      meals: _displayedMeals,
      onMealSelected: (meal) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipePage(
              mealId: meal.idMeal,
              mealName: meal.strMeal,
            ),
          ),
        );
      },
      scrollController: _scrollController,
      isLoading: _isLoadingMore,
      hasMore: _hasMore,
    );
  }
}
