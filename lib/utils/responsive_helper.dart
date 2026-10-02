import 'package:flutter/material.dart';
import 'package:recipe_explorer/constants/ui_constants.dart';

class ResponsiveHelper {
  // Determines if the device is a mobile based on screen width
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < UIConstants.mobileMaxWidth;

  // Determines if the device is a tablet based on screen width
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= UIConstants.mobileMaxWidth &&
      MediaQuery.of(context).size.width < UIConstants.tabletMaxWidth;

  // Determines if the device is a desktop based on screen width
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= UIConstants.tabletMaxWidth;

  // Returns the number of grid columns based on the device type
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return UIConstants.mobileGridColumns;
    if (isTablet(context)) return UIConstants.tabletGridColumns;
    return UIConstants.desktopGridColumns;
  }

  /// Grid delegate for meal cards laid out in [availableWidth].
  ///
  /// Uses a fixed row extent (square image + info block) instead of an aspect
  /// ratio, so every card keeps the same image size regardless of title length
  /// and the info block grows with the system text scale.
  static SliverGridDelegate mealGridDelegate(
    BuildContext context,
    double availableWidth,
  ) {
    final columns = getGridCrossAxisCount(context);
    final tileWidth =
        (availableWidth - UIConstants.gridSpacing * (columns - 1)) / columns;
    final infoHeight = MediaQuery.textScalerOf(context)
        .scale(UIConstants.mealCardInfoHeight);

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: UIConstants.gridSpacing,
      mainAxisSpacing: UIConstants.gridSpacing,
      mainAxisExtent: tileWidth * UIConstants.mealCardImageRatio + infoHeight,
    );
  }
}
