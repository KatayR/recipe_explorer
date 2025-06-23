import 'package:get/get.dart';
import '../models/meal_model.dart';
import 'storage_service.dart';

class FavoritesController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  
  // Reactive state variables
  var isLoading = false.obs;
  var favorites = <Meal>[].obs;
  var favoriteIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  /// Load favorites from storage and update reactive state
  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      final loadedFavorites = await _storage.getAllFavorites();
      favorites.value = loadedFavorites;
      favoriteIds.assignAll(loadedFavorites.map((meal) => meal.idMeal).toSet());
    } finally {
      isLoading.value = false;
    }
  }

  /// Get all favorite meals from storage
  Future<List<Meal>> getFavorites() async {
    return await _storage.getAllFavorites();
  }

  /// Check if a meal is marked as favorite (reactive)
  bool isFavorite(String mealId) {
    return favoriteIds.contains(mealId);
  }
  
  /// Check if a meal is marked as favorite (async for backward compatibility)
  Future<bool> isFavoriteAsync(String mealId) async {
    return await _storage.isFavorite(mealId);
  }

  /// Toggle favorite status of a meal (reactive)
  /// Returns the new favorite status (true if added, false if removed)
  Future<bool> toggleFavorite(Meal meal) async {
    final isFav = isFavorite(meal.idMeal);

    if (isFav) {
      // Remove from favorites
      await _storage.removeFromFavorites(meal.idMeal);
      favorites.removeWhere((m) => m.idMeal == meal.idMeal);
      favoriteIds.remove(meal.idMeal);
      return false;
    } else {
      // Add to favorites
      await _storage.addToFavorites(meal);
      favorites.add(meal);
      favoriteIds.add(meal.idMeal);
      return true;
    }
  }

  /// Get a specific favorite meal by ID
  /// Returns null if meal is not in favorites
  Future<Meal?> getFavoriteMeal(String mealId) async {
    return await _storage.getFavoriteMeal(mealId);
  }

  // Load meal data (either from favorites if saved, or return null)
  Future<Meal?> loadMealIfSaved(String mealId) async {
    if (isFavorite(mealId)) {
      return await getFavoriteMeal(mealId);
    }
    return null;
  }
}

// Backward compatibility - keep old FavoritesService for gradual migration
class FavoritesService {
  final FavoritesController _controller = Get.find<FavoritesController>();
  
  Future<List<Meal>> getFavorites() => _controller.getFavorites();
  Future<bool> isFavorite(String mealId) async => _controller.isFavorite(mealId);
  Future<bool> toggleFavorite(Meal meal) => _controller.toggleFavorite(meal);
  Future<Meal?> getFavoriteMeal(String mealId) => _controller.getFavoriteMeal(mealId);
  Future<Meal?> loadMealIfSaved(String mealId) => _controller.loadMealIfSaved(mealId);
}
