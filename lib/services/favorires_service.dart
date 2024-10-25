import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  Future<List<String>> getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorites') ?? [];
  }

  Future<void> toggleFavorite(String mealId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];

    if (favorites.contains(mealId)) {
      favorites.remove(mealId);
    } else {
      favorites.add(mealId);
    }

    await prefs.setStringList('favorites', favorites);
  }
}
