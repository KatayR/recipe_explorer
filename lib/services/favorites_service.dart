import 'package:get/get.dart';
import '../models/meal_model.dart';
import 'storage_service.dart';

class FavoritesService {
  final StorageService _storage = Get.find<StorageService>();

  /// Get all favorite meals from storage
  Future<List<Meal>> getFavorites() async {
    return await _storage.getAllFavorites();
  }

  /// Check if a meal is marked as favorite
  Future<bool> isFavorite(String mealId) async {
    return await _storage.isFavorite(mealId);
  }

  /// Toggle favorite status of a meal
  /// Returns the new favorite status (true if added, false if removed)
  Future<bool> toggleFavorite(Meal meal) async {
    final isFav = await isFavorite(meal.idMeal);

    if (isFav) {
      // Remove from favorites
      await _storage.removeFromFavorites(meal.idMeal);
      return false;
    } else {
      // Add to favorites
      await _storage.addToFavorites(meal);
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
    if (await isFavorite(mealId)) {
      return await getFavoriteMeal(mealId);
    }
    return null;
  }
}
