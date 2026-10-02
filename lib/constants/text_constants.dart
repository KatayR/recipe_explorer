/// Text constants
class TextConstants {
  // App bar titles
  static const String appTitle = 'Recipe Explorer';
  static const String favoritesTitle = 'Favorites';
  static const String genericResultsTitle = 'Results';

  // Home
  static const String homeHeadline = 'What are we cooking today?';
  static const String categoriesTitle = 'Categories';
  static const String defaultCategoryTitle = 'Cooking with chicken';
  static const String defaultCategorySubtitle = 'A few ideas to get you started';
  static const String offlineHeadline = 'You\'re offline';

  // Search related
  static const String searchHint = 'Search recipes…';
  static const String filtersTitle = 'Search by';
  static const String filtersSubtitle = 'Choose what your search should match.';
  static const String searchByName = 'Recipe name';
  static const String searchByIngredient = 'Ingredient';
  static const String invalidSearchTitle = 'Invalid search';
  static const String noFilterSelectedTitle = 'No search filter selected';

  // Recipe details
  static const String ingredientsTitle = 'Ingredients';
  static const String instructionsTitle = 'Instructions';

  // Error messages
  static const String noInternetError = 'No internet connection';
  static const String loadError =
      'Failed to load. Please check your connection.';
  static const String offlineMessage =
      'Check your connection and try again. Your favorites are still available offline.';
  static const String noResultsError = 'No recipes found';
  static const String noResultsMessage =
      'Try a different word, or switch between name and ingredient search.';
  static const String imageLoadError = 'Image unavailable';
  static const String noFavoritesMessage = 'No favorites yet';
  static const String addFavoritesMessage =
      'Tap the heart on any recipe to keep it here, even offline.';
  static const String recipeLoadingError =
      'Unable to load recipe. Please check your internet connection.';
  static const String defaultCategoryError =
      'Error loading sample dishes. Check your connection and try again';
  static const String categoriesLoadError = 'Couldn\'t load categories';
  static const String noMealDetailsError = 'No details found for this meal.';

  // Buttons
  static const String tryAgainButton = 'Try again';
  static const String doneButton = 'Done';
  static const String browseRecipesButton = 'Browse recipes';
  static const String favoritesTooltip = 'Favorites';
  static const String addFavoriteTooltip = 'Add to favorites';
  static const String removeFavoriteTooltip = 'Remove from favorites';
  static const String filtersTooltip = 'Search filters';

  // Counts
  static String recipeCount(int count) =>
      '$count ${count == 1 ? 'recipe' : 'recipes'}';
  static String savedRecipeCount(int count) =>
      '$count saved ${count == 1 ? 'recipe' : 'recipes'}';
  static String itemCount(int count) =>
      '$count ${count == 1 ? 'item' : 'items'}';
  static String stepCount(int count) =>
      '$count ${count == 1 ? 'step' : 'steps'}';
}
