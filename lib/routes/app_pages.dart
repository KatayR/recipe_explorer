import 'package:get/get.dart';
import '../screens/home/home_page.dart';
import '../screens/favorites/favorites_page.dart';
import '../screens/results/results_page.dart';
import '../screens/recipe/recipe_page.dart';
import 'app_routes.dart';

/// GetX page configuration for named route navigation
class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesPage(),
    ),
    GetPage(
      name: AppRoutes.results,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return ResultsPage(
          searchQuery: args[AppRoutes.searchQueryParam] as String?,
          categoryName: args[AppRoutes.categoryNameParam] as String?,
          searchByName: args[AppRoutes.searchByNameParam] as bool? ?? true,
          searchByIngredient: args[AppRoutes.searchByIngredientParam] as bool? ?? false,
        );
      },
    ),
    GetPage(
      name: AppRoutes.recipe,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return RecipePage(
          mealId: args[AppRoutes.mealIdParam] as String,
          mealName: args[AppRoutes.mealNameParam] as String,
        );
      },
    ),
  ];
}