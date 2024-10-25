import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorites';

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<bool> isFavorite(String mealId) async {
    final favorites = await getFavorites();
    return favorites.any((item) => jsonDecode(item)['idMeal'] == mealId);
  }

  Future<void> toggleFavorite(Map<String, dynamic> mealJson) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    final mealString = jsonEncode(mealJson);

    if (favorites.contains(mealString)) {
      favorites.remove(mealString);
    } else {
      favorites.add(mealString);
    }

    await prefs.setStringList(_key, favorites);
  }
}
