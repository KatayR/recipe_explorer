import 'dart:convert';
import 'package:http/http.dart' as http;

class MealResponse {
  final List<dynamic> meals;
  final String? error;

  MealResponse({
    required this.meals,
    this.error,
  });
}

class MealService {
  final String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<MealResponse> fetchMeals({
    String? searchQuery,
    String? category,
    String? ingredient,
  }) async {
    try {
      List<dynamic> results = [];

      if (searchQuery != null) {
        final nameResults = await searchMealsByName(searchQuery);
        final ingredientResults = await searchMealsByIngredient(searchQuery);
        results = {...nameResults, ...ingredientResults}.toList();
      } else if (category != null) {
        results = await getMealsByCategory(category);
      } else if (ingredient != null) {
        results = await searchMealsByIngredient(ingredient);
      }

      return MealResponse(
        meals: results,
      );
    } catch (e) {
      return MealResponse(
        meals: [],
        error: e.toString(),
      );
    }
  }

  Future<List<dynamic>> searchMealsByName(String query) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/search.php?s=$query'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['meals'] ?? [];
      }
      throw Exception('Failed to load meals');
    } catch (e) {
      print('Error searching meals by name: $e');
      return [];
    }
  }

  Future<List<dynamic>> searchMealsByIngredient(String ingredient) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/filter.php?i=$ingredient'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['meals'] ?? [];
      } else {
        throw Exception('Failed to load meals by ingredient');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['categories'];
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getMealsByCategory(String category) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/filter.php?c=$category'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['meals'] ?? [];
      } else {
        throw Exception('Failed to load meals by category');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
