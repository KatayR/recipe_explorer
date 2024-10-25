import '../widgets/home/custom_search_bar.dart';
import 'meals_service.dart';

class ResultsManager {
  final MealService mealService;
  final Function(List<dynamic>) onResultsLoaded;
  final Function(String) onError;
  List<dynamic> _allResults = [];

  ResultsManager({
    required this.mealService,
    required this.onResultsLoaded,
    required this.onError,
  });

  Future<void> loadResults({
    String? searchQuery,
    String? categoryName,
    SearchOptions? searchOptions,
  }) async {
    try {
      List<dynamic> results = [];

      if (searchQuery != null && searchOptions != null) {
        results = await _loadSearchResults(searchQuery, searchOptions);
      } else if (categoryName != null) {
        results = await mealService.getMealsByCategory(categoryName);
      }

      _allResults = results;
      onResultsLoaded(results);
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<List<dynamic>> _loadSearchResults(
      String query, SearchOptions options) async {
    final futures = <Future<List<dynamic>>>[];

    if (options.byName) {
      futures.add(mealService.searchMealsByName(query));
    }
    if (options.byIngredient) {
      futures.add(mealService.searchMealsByIngredient(query));
    }

    final responses = await Future.wait(futures);
    final allResults = responses.expand((x) => x).toList();

    return options.byName && options.byIngredient
        ? {...allResults}.toList()
        : allResults;
  }

  List<dynamic> getNextBatch({
    required int currentLength,
    required int batchSize,
  }) {
    return _allResults.skip(currentLength).take(batchSize).toList();
  }
}
