import 'package:flutter/material.dart';
import '../screens/recipe_page.dart';
import '../services/meals_service.dart';
import '../services/results_manager.dart';
import '../widgets/home/custom_search_bar.dart';
import '../widgets/results_content.dart';

class ResultsPage extends StatefulWidget {
  final String? searchQuery;
  final String? categoryName;
  final SearchOptions? searchOptions;

  const ResultsPage({
    super.key,
    this.searchQuery,
    this.categoryName,
    this.searchOptions,
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
  late final ResultsManager _resultsManager;
  final int _batchSize = 10;

  @override
  void initState() {
    super.initState();
    _resultsManager = ResultsManager(
      mealService: _mealService,
      onResultsLoaded: _handleResultsLoaded,
      onError: _handleError,
    );
    _scrollController.addListener(_onScroll);
    _loadInitialResults();
  }

  void _handleResultsLoaded(List<dynamic> results) {
    setState(() {
      _allMeals = results;
      _displayedResults.addAll(results.take(_batchSize));
      _hasMore = _displayedResults.length < _allMeals.length;
      _isLoading = false;
    });
    print(
        'Initial load: Total items: ${_allMeals.length}, \nCurrently shown: ${_displayedResults.length}, Remaining: ${_allMeals.length - _displayedResults.length}');
  }

  void _handleError(String error) {
    setState(() {
      _isLoading = false;
      _hasMore = false;
    });
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
    await _resultsManager.loadResults(
      searchQuery: widget.searchQuery,
      categoryName: widget.categoryName,
      searchOptions: widget.searchOptions,
    );
  }

  Future<void> _loadNextBatch() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    final nextBatch = _resultsManager.getNextBatch(
      currentLength: _displayedResults.length,
      batchSize: _batchSize,
    );

    setState(() {
      _displayedResults.addAll(nextBatch);
      _hasMore = _displayedResults.length < _allMeals.length;
      _isLoadingMore = false;
    });
    print(
        'Loaded next batch: Newly added: ${nextBatch.length}, \nCurrently shown: ${_displayedResults.length}, \nRemaining: ${_allMeals.length - _displayedResults.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
      ),
      body: ResultsContent(
        meals: _displayedResults,
        isLoading: _isLoading,
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
    if (widget.searchQuery != null) {
      return 'Search Results: ${widget.searchQuery}';
    } else {
      return 'Category: ${widget.categoryName}';
    }
  }
}
