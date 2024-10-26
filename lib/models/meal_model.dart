class Meal {
  final String idMeal;
  final String strMeal;
  final String? strDrinkAlternate;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strMealThumb;
  final String strTags;
  final String strYoutube;
  final List<String> ingredients;
  final List<String> measures;

  Meal({
    required this.idMeal,
    required this.strMeal,
    this.strDrinkAlternate,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    required this.strTags,
    required this.strYoutube,
    required this.ingredients,
    required this.measures,
  });

  // Factory constructor for creating a Meal object from JSON
  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> extractIngredients(Map<String, dynamic> json) {
      List<String> ingredients = [];
      for (int i = 1; i <= 20; i++) {
        String ingredient = json['strIngredient$i'] ?? '';
        if (ingredient.isNotEmpty) {
          ingredients.add(ingredient);
        }
      }
      return ingredients;
    }

    List<String> extractMeasures(Map<String, dynamic> json) {
      List<String> measures = [];
      for (int i = 1; i <= 20; i++) {
        String measure = json['strMeasure$i'] ?? '';
        if (measure.isNotEmpty) {
          measures.add(measure);
        }
      }
      return measures;
    }

    return Meal(
      idMeal: json['idMeal'],
      strMeal: json['strMeal'],
      strDrinkAlternate: json['strDrinkAlternate'],
      strCategory: json['strCategory'] ?? '',
      strArea: json['strArea'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strTags: json['strTags'] ?? '',
      strYoutube: json['strYoutube'] ?? '',
      ingredients: extractIngredients(json),
      measures: extractMeasures(json),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strDrinkAlternate': strDrinkAlternate,
      'strCategory': strCategory,
      'strArea': strArea,
      'strInstructions': strInstructions,
      'strMealThumb': strMealThumb,
      'strTags': strTags,
      'strYoutube': strYoutube,
    };

    for (int i = 0; i < ingredients.length; i++) {
      data['strIngredient${i + 1}'] = ingredients[i];
      data['strMeasure${i + 1}'] = measures[i];
    }

    return data;
  }
}
