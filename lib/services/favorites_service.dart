import 'dart:convert';
import './database_helper.dart';
import '../models/meal_model.dart';
import 'image_cache.dart';

class FavoritesService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ImageCacheService _imageCache = ImageCacheService.instance;

  Future<List<Meal>> getFavorites() async {
    final favorites = await _dbHelper.getAllFavorites();
    return favorites
        .map((mealJson) => Meal.fromJson(jsonDecode(mealJson)))
        .toList();
  }

  Future<bool> isFavorite(String mealId) async {
    return await _dbHelper.isFavorite(mealId);
  }

  Future<void> toggleFavorite(Map<String, dynamic> mealJson) async {
    final mealId = mealJson['idMeal'] as String;
    final isFav = await isFavorite(mealId);

    if (isFav) {
      await _dbHelper.removeFavorite(mealId);
      await _imageCache.removeImage(mealId);
    } else {
      // Caching the image using meal ID
      await _imageCache.cacheImage(mealId, mealJson['strMealThumb'] as String);
      await _dbHelper.addFavorite(mealId, jsonEncode(mealJson));
    }
  }

  Future<Meal?> getFavoriteMeal(String mealId) async {
    final mealJson = await _dbHelper.getFavoriteMeal(mealId);
    if (mealJson != null) {
      return Meal.fromJson(jsonDecode(mealJson));
    }
    return null;
  }
}
