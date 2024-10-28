import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/meal_model.dart';
import '../../services/favorites_service.dart';

/// Provider for the FavoritesService instance
final favoritesServiceProvider =
    Provider<FavoritesService>((ref) => FavoritesService());

/// Provider for the list of favorite meals
final favoriteMealsProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<List<Meal>>>((ref) {
  final favoritesService = ref.watch(favoritesServiceProvider);
  return FavoritesNotifier(favoritesService);
});

/// Notifier to manage favorites state
class FavoritesNotifier extends StateNotifier<AsyncValue<List<Meal>>> {
  final FavoritesService _favoritesService;

  /// Constructor for FavoritesNotifier
  ///
  /// Initializes the state to loading and loads the favorites.
  FavoritesNotifier(this._favoritesService)
      : super(const AsyncValue.loading()) {
    loadFavorites();
  }

  /// Loads the list of favorite meals from the FavoritesService.
  ///
  /// Sets the state to loading while fetching the data and updates the state
  /// with the fetched data or an error if the fetch fails.
  Future<void> loadFavorites() async {
    try {
      state = const AsyncValue.loading();
      final favorites = await _favoritesService.getFavorites();
      state = AsyncValue.data(favorites);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Toggles the favorite status of a meal.
  ///
  /// Calls the toggleFavorite method on the FavoritesService and reloads the
  /// list of favorite meals.
  ///
  /// Prints an error message if the toggle operation fails.
  Future<void> toggleFavorite(Meal meal) async {
    try {
      await _favoritesService.toggleFavorite(meal);
      loadFavorites();
    } catch (error) {
      print('Error toggling favorite: $error');
    }
  }

  /// Checks if a meal is marked as favorite.
  ///
  /// Returns a boolean indicating whether the meal with the given ID is a favorite.
  Future<bool> isFavorite(String mealId) async {
    return _favoritesService.isFavorite(mealId);
  }
}
