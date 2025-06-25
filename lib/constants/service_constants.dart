class ApiConstants {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String randomMealEndpoint = '/random.php';
  static const String categoriesEndpoint = '/categories.php';
  static const String searchByNameEndpoint = '/search.php?s=';
  static const String filterByCategoryEndpoint = '/filter.php?c=';
  static const String searchByIngredientEndpoint = '/filter.php?i=';

  // HTTP timeout duration
  static const int connectionTimeout = 5; // seconds
}

/// Database related constants
/// Risky to use
class DatabaseConstants {
  static const String databaseName = 'recipes.db';
  static const String favoritesTable = 'favorites';
  static const int databaseVersion = 1;

  // Table columns
  static const String columnId = 'id';
  static const String columnMealData = 'mealData';
}

/// Asset paths and cache related constants
class AssetConstants {
  static const String cacheDirName = 'cached_images';
  static const String databaseDirName = 'databases';
  static const String imageExtension = '.jpg';
}
