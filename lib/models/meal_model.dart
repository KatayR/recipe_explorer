import '../constants/app_constants.dart';

class Meal {
  final String idMeal; // Unique identifier for the meal
  final String strMeal; // Name of the meal
  final String strCategory; // Category of the meal
  final String strArea; // Cuisine/region of origin
  final String strInstructions; // Cooking instructions
  final String strMealThumb; // URL for meal thumbnail image
  final List<String> ingredients; // List of ingredients
  final List<String> measures; // List of corresponding measurements

  Meal({
    required this.idMeal,
    required this.strMeal,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    required this.ingredients,
    required this.measures,
  });

  /// Helper function to extract ingredients from JSON
  /// Processes up to ${AppConstants.maxIngredientsPerMeal}(due to hard-coded API limit) ingredients, skipping empty ones
  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> extractIngredients(Map<String, dynamic> json) {
      List<String> ingredients = [];
      for (int i = 1; i <= AppConstants.maxIngredientsPerMeal; i++) {
        String ingredient = json['strIngredient$i'] ?? '';
        if (ingredient.isNotEmpty) {
          ingredients.add(ingredient);
        }
      }
      return ingredients;
    }

    /// Helper function to extract measurements from JSON
    /// Processes up to ${AppConstants.maxMeasurementsPerMeal}(due to hard-coded API limit) measurements, skipping empty ones
    List<String> extractMeasures(Map<String, dynamic> json) {
      List<String> measures = [];
      for (int i = 1; i <= AppConstants.maxMeasurementsPerMeal; i++) {
        String measure = json['strMeasure$i'] ?? '';
        if (measure.isNotEmpty) {
          measures.add(measure);
        }
      }
      return measures;
    }

    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? 'Unknown Recipe',
      strCategory: json['strCategory'] ?? '',
      strArea: json['strArea'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      ingredients: extractIngredients(json),
      measures: extractMeasures(json),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strCategory': strCategory,
      'strArea': strArea,
      'strInstructions': strInstructions,
      'strMealThumb': strMealThumb,
    };

    // Add ingredients and measurements to JSON
    for (int i = 0; i < ingredients.length; i++) {
      data['strIngredient${i + 1}'] = ingredients[i];
      data['strMeasure${i + 1}'] = measures[i];
    }

    return data;
  }
}
