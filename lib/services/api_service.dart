import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_explorer/constants/service_constants.dart';

/// Service class for handling all API communications
class ApiResponse<T> {
  final T? data;
  final String? error;

  ApiResponse({this.data, this.error});
}

class ApiController extends GetxController {
  // Reactive state variables
  var isLoading = false.obs;
  var error = Rx<String?>(null);
  // Base URL for the API
  static const String baseUrl = ApiConstants.baseUrl;
  static const String categoriesEndpoint = ApiConstants.categoriesEndpoint;
  static const String searchByNameEndpoint = ApiConstants.searchByNameEndpoint;
  static const String filterByCategoryEndpoint =
      ApiConstants.filterByCategoryEndpoint;
  static const String searchByIngredientEndpoint =
      ApiConstants.searchByIngredientEndpoint;

  /// Fetches meal categories from the API
  /// Returns a list of category data or error message
  Future<ApiResponse<List<dynamic>>> getCategories() async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final response =
          await http.get(Uri.parse('$baseUrl/$categoriesEndpoint'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(data: data['categories']);
      }
      const errorMsg = 'Failed to load categories';
      error.value = errorMsg;
      return ApiResponse(error: errorMsg);
    } catch (e) {
      final errorMsg = 'Network error: $e';
      error.value = errorMsg;
      return ApiResponse(error: errorMsg);
    } finally {
      isLoading.value = false;
    }
  }

  /// Searches meals by name
  /// [query] is the search term
  Future<ApiResponse<List<dynamic>>> searchMealsByName(String query) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/$searchByNameEndpoint$query'));
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
      final response = await http
          .get(Uri.parse('$baseUrl/$searchByIngredientEndpoint$ingredient'));
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
      final response = await http
          .get(Uri.parse('$baseUrl/$filterByCategoryEndpoint$category'));
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

// Backward compatibility - keep old ApiService for gradual migration
class ApiService {
  final ApiController _controller = Get.find<ApiController>();
  
  Future<ApiResponse<List<dynamic>>> getCategories() => _controller.getCategories();
  Future<ApiResponse<List<dynamic>>> searchMealsByName(String query) => _controller.searchMealsByName(query);
  Future<ApiResponse<List<dynamic>>> searchMealsByIngredient(String ingredient) => _controller.searchMealsByIngredient(ingredient);
  Future<ApiResponse<List<dynamic>>> getMealsByCategory(String category) => _controller.getMealsByCategory(category);
  Future<ApiResponse<List<dynamic>>> searchMeals({
    required String query,
    bool searchByName = true,
    bool searchByIngredient = false,
  }) => _controller.searchMeals(query: query, searchByName: searchByName, searchByIngredient: searchByIngredient);
}
