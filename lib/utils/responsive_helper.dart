import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Determines if the device is a mobile based on screen width
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  // Determines if the device is a tablet based on screen width
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  // Determines if the device is a desktop based on screen width
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  // Returns the number of grid columns based on the device type
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  // Returns the aspect ratio of grid children based on the device type
  static double getGridChildAspectRatio(BuildContext context) {
    if (isMobile(context)) return 0.85;
    if (isTablet(context)) return 0.75;
    return 0.7;
  }
}
