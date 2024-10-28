/// A page that displays the user's favorite meals. This page uses the
/// `ConsumerWidget` from Riverpod to listen to the `favoriteMealsProvider`
/// and update the UI accordingly.
///
/// The page shows a loading view while the favorite meals are being fetched,
/// an error view if there is an error during fetching, and a grid of meals
/// if the data is successfully fetched. If there are no favorite meals,
/// a message encouraging the user to add favorites is displayed.
///
/// The user can tap on a meal to navigate to the `RecipePage` for that meal.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/text_constants.dart';
import '../../constants/ui_constants.dart';
import '../../services/favorites_provider.dart';
import '../../widgets/error/error_view.dart';
import '../../widgets/loading/loading_view.dart';
import '../../widgets/meal/meal_grid.dart';
import '../recipe/recipe_page.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Watches the state of the favorite meals provider and assigns it to the `favoritesState` variable.
    ///
    /// This allows the widget to reactively rebuild whenever the state of the favorite meals changes.
    final favoritesState = ref.watch(favoriteMealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(TextConstants.favoritesTitle),
      ),
      body: favoritesState.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          errString: TextConstants.loadError,
          onRetry: () =>

              /// Loads the favorite meals using the `favoriteMealsProvider` notifier.
              ///
              /// This method reads the `favoriteMealsProvider` and triggers the
              /// `loadFavorites` function to fetch and update the list of favorite meals.
              ref.read(favoriteMealsProvider.notifier).loadFavorites(),
        ),
        data: (meals) {
          if (meals.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: UIConstants.defaultSpacing),
                  Text(TextConstants.noFavoritesMessage),
                  SizedBox(height: UIConstants.defaultPadding),
                  Text(TextConstants.addFavoritesMessage),
                ],
              ),
            );
          }

          return MealGrid(
            meals: meals.map((meal) => meal.toJson()).toList(),
            onMealSelected: (meal) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipePage(
                  mealId: meal.idMeal,
                  mealName: meal.strMeal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
