/// Application-wide constants for business logic and magic numbers
class AppConstants {
  // API and Data Constants
  /// Maximum number of ingredients supported by TheMealDB API
  static const int maxIngredientsPerMeal = 20;
  
  /// Maximum number of measurements supported by TheMealDB API  
  static const int maxMeasurementsPerMeal = 20;
  
  /// HTTP success status code
  static const int httpSuccessCode = 200;
  
  // Image Preloading Constants
  /// Standard number of images to preload initially
  static const int standardImagePreloadCount = 15;
  
  /// Number of items to preload ahead during scrolling
  static const int scrollAheadPreloadCount = 20;
  
  /// Minimum remaining items threshold for end-of-list preloading
  static const int endOfListThreshold = 5;
  
  /// Estimated memory per cached image in MB
  static const double estimatedMemoryPerImageMB = 0.5;
  
  /// Delay between image preload requests in milliseconds
  static const int preloadDelayMs = 75;
  
  // Scroll and Animation Constants
  /// Default scroll offset for category navigation
  static const double categoryScrollOffset = 200.0;
  
  /// Default timeout for network requests in seconds
  static const int networkTimeoutSeconds = 5;
  
  // Responsive Design Breakpoints (extracted from magic numbers in UI)
  /// Mobile category list height
  static const double mobileCategoryHeight = 100.0;
  
  /// Desktop category list height  
  static const double desktopCategoryHeight = 120.0;
  
  /// Mobile category item width
  static const double mobileCategoryWidth = 90.0;
  
  /// Desktop category item width
  static const double desktopCategoryWidth = 150.0;
  
  /// Mobile category text size
  static const double mobileCategoryTextSize = 12.0;
  
  /// Desktop category text size
  static const double desktopCategoryTextSize = 14.0;
  
  // Widget Dimensions (frequently used magic numbers)
  /// Standard icon size for small icons
  static const double smallIconSize = 20.0;
  
  /// Recipe image height for mobile devices
  static const double mobileRecipeImageHeight = 200.0;
  
  /// Recipe image height for desktop devices  
  static const double desktopRecipeImageHeight = 400.0;
  
  /// Recipe image width for desktop devices
  static const double desktopRecipeImageWidth = 400.0;
  
  // Input Validation Constants
  /// Minimum length for search queries
  static const int minSearchQueryLength = 2;
  
  /// Maximum length for search queries
  static const int maxSearchQueryLength = 50;
  
  /// Regex pattern for valid search characters (letters, numbers, spaces, basic punctuation)
  static const String searchQueryPattern = r'^[a-zA-Z0-9\s\-\.,&]+$';
  
  /// List of inappropriate/blocked search terms
  static const List<String> blockedSearchTerms = [
    'script',
    'javascript',
    'eval',
    'alert',
    'onload',
    'onclick',
  ];
}