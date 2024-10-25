import 'dart:convert';
import 'package:http/http.dart' as http;

class MealService {
  final String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<dynamic>> searchMealsByName(String query) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/search.php?s=$query'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['meals'] ?? [];
      } else {
        throw Exception('Failed to load meals');
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
