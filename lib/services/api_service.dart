import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service class for handling all API communications
class ApiResponse<T> {
  final T? data;
  final String? error;

  ApiResponse({this.data, this.error});
}

class ApiService {
  // Base URL for the API
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Fetches meal categories from the API
  /// Returns a list of category data or error message
  Future<ApiResponse<List<dynamic>>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(data: data['categories']);
      }
      return ApiResponse(error: 'Failed to load categories');
    } catch (e) {
      return ApiResponse(error: 'Network error: $e');
    }
  }

  /// Searches meals by name
  /// [query] is the search term
  Future<ApiResponse<List<dynamic>>> searchMealsByName(String query) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/search.php?s=$query'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(data: data['meals'] ?? []);
      }
      return ApiResponse(error: 'Failed to search meals');
    } catch (e) {
      return ApiResponse(error: 'Network error: $e');
    }
  }

  /// Searches meals by ingredient
  /// [ingredient] is the ingredient to search for
  Future<ApiResponse<List<dynamic>>> searchMealsByIngredient(
      String ingredient) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/filter.php?i=$ingredient'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(data: data['meals'] ?? []);
      }
      return ApiResponse(error: 'Failed to search by ingredient');
    } catch (e) {
      return ApiResponse(error: 'Network error: $e');
    }
  }

  /// Gets meals by category
  /// [category] is the category name to filter by
  Future<ApiResponse<List<dynamic>>> getMealsByCategory(String category) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/filter.php?c=$category'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(data: data['meals'] ?? []);
      }
      return ApiResponse(error: 'Failed to load meals by category');
    } catch (e) {
      return ApiResponse(error: 'Network error: $e');
    }
  }

  /// Searches meals using combined criteria (name and/or ingredients)
  /// [query] is the search term
  /// [searchByName] whether to search by meal name
  /// [searchByIngredient] whether to search by ingredient
  Future<ApiResponse<List<dynamic>>> searchMeals({
    required String query,
    bool searchByName = true,
    bool searchByIngredient = false,
  }) async {
    try {
      List<dynamic> results = [];

      // Search by name if enabled
      if (searchByName) {
        final nameResponse = await searchMealsByName(query);
        if (nameResponse.error == null) {
          results.addAll(nameResponse.data!);
        } else {
          return nameResponse;
        }
      }

      // Search by ingredient if enabled
      if (searchByIngredient) {
        final ingredientResponse = await searchMealsByIngredient(query);
        if (ingredientResponse.error == null) {
          results.addAll(ingredientResponse.data!);
        } else {
          return ingredientResponse;
        }
      }

      // Remove duplicates by converting to Set and back to List
      return ApiResponse(data: {...results}.toList());
    } catch (e) {
      return ApiResponse(error: 'Search failed: $e');
    }
  }
}
