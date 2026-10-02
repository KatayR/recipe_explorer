/// Layout, sizing and spacing constants shared by the UI layer.
class UIConstants {
  // Breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1200;

  // Meal grid
  static const int mobileGridColumns = 2;
  static const int tabletGridColumns = 3;
  static const int desktopGridColumns = 4;
  static const double gridSpacing = 12.0;

  /// Image height / tile width on meal cards (1.0 = square, matching TheMealDB thumbs).
  static const double mealCardImageRatio = 1.0;

  /// Height reserved under the image for title (2 lines) + cuisine chip, before text scaling.
  static const double mealCardInfoHeight = 96.0;

  // Padding and spacing
  static const double defaultPadding = 8.0;
  static const double doublePadding = 16.0;
  static const double pagePadding = 20.0;
  static const double defaultSpacing = 16.0;
  static const double sectionSpacing = 24.0;

  // Radii
  static const double cardRadius = 16.0;
  static const double tileRadius = 20.0;
  static const double pillRadius = 28.0;

  // Categories strip
  static const double categoryTileSize = 88.0;
  static const double categoryTileSizeDesktop = 112.0;
  static const double categoryItemWidth = 104.0;
  static const double categoryItemWidthDesktop = 132.0;

  // Recipe page
  static const double recipeHeroHeight = 320.0;
  static const double recipeHeroHeightWide = 420.0;
  static const double recipeContentMaxWidth = 1040.0;

  // Misc
  static const double smallIconSize = 20.0;
}
