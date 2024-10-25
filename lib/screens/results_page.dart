import 'package:flutter/material.dart';
import '../screens/recipe_page.dart';
import '../services/meals_service.dart';
import '../widgets/meal_list/paginated_meal_list.dart';

enum QueryType { search, category }

class ResultsPage extends StatefulWidget {
  final String? searchQuery;
  final String? categoryName;

  const ResultsPage({
    super.key,
    this.searchQuery,
    this.categoryName,
  });

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final MealService _mealService = MealService();
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _displayedResults = [];
  List<dynamic> _allMeals = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  // Constants for layout calculations
  static const double _listItemHeight = 68.0; // Card height + vertical margins
  static const double _loadingBufferPercent = 0.2; // 20% extra items

  // Dynamic page size based on screen height
  late int _pageSize;
  late QueryType queryType;

  @override
  void initState() {
    super.initState();
    queryType =
        widget.searchQuery != null ? QueryType.search : QueryType.category;
    _scrollController.addListener(_onScroll);
    _loadInitialResults();
  }

  void _initializePageSize() {
    // Getting the available height for the list
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - appBarHeight - statusBarHeight;

    // Calculating how many items fit in the screen
    final itemsPerScreen = (availableHeight / _listItemHeight).ceil();

    // Adding 20% more items
    _pageSize = (itemsPerScreen * (1 + _loadingBufferPercent)).ceil();

    print(
        'Screen can fit $itemsPerScreen items, loading (max) $_pageSize items');
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadNextBatch();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialResults() async {
    try {
      List<dynamic> results = [];

      if (queryType == QueryType.search) {
        final mealsByName =
            await _mealService.searchMealsByName(widget.searchQuery!);
        final mealsByIngredient =
            await _mealService.searchMealsByIngredient(widget.searchQuery!);
        results = {...mealsByName, ...mealsByIngredient}.toList();
      } else if (queryType == QueryType.category) {
        results = await _mealService.getMealsByCategory(widget.categoryName!);
      }

      setState(() {
        _allMeals = results;
        _isLoading = false;
      });

      // Initializng page size and load first batch after layout
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializePageSize();
        _loadNextBatch();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
      print('Error loading results: $e');
    }
  }

  Future<void> _loadNextBatch() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final currentLength = _displayedResults.length;
      print("currentLength : $currentLength");
      final remainingMeals = _allMeals.length - currentLength;
      print("remainingMeals : $remainingMeals");

      if (remainingMeals > 0) {
        final nextBatch =
            _allMeals.skip(currentLength).take(_pageSize).toList();

        setState(() {
          _displayedResults.addAll(nextBatch);
          _hasMore = _displayedResults.length < _allMeals.length;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
      print('Error loading more meals: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        leading: BackButton(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PaginatedMealList(
              meals: _displayedResults,
              isLoading: _isLoadingMore,
              hasMore: _hasMore,
              scrollController: _scrollController,
              onMealSelected: (mealName) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetail(mealName: mealName),
                  ),
                );
              },
            ),
    );
  }

  String _getPageTitle() {
    return widget.searchQuery != null
        ? 'Search Results: ${widget.searchQuery}'
        : 'Category: ${widget.categoryName}';
  }
}
