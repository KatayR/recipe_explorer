/// A widget that displays a section of default recipes fetched from an API.
///
/// The `DefaultRecipesSection` widget is a stateless widget that fetches and displays
/// a list of sample dishes that can be made with chicken. It uses the `ApiService`
/// to fetch the data and displays it in a grid format. If there is an error during
/// the fetch operation or if the data is still loading, appropriate views are shown.
///
/// This widget requires an instance of `ApiService` to be passed as a required parameter.
///
/// Example usage:
/// ```dart
/// DefaultRecipesSection(apiService: myApiServiceInstance);
/// ```
///
/// The widget consists of:
/// - A title indicating the type of dishes being displayed.
/// - A `FutureBuilder` that handles the asynchronous fetching of data.
/// - A `LoadingView` that is displayed while the data is being fetched.
/// - An `ErrorView` that is displayed if there is an error during the fetch operation.
/// - A `MealGrid` that displays the fetched meals in a grid format.
///
/// When a meal is selected from the grid, the user is navigated to the `RecipePage`
/// for that specific meal.

import 'package:flutter/material.dart';
import 'package:recipe_explorer/widgets/error/error_view.dart';
import '../../../services/api_service.dart';
import '../../../widgets/loading/loading_view.dart';
import '../../../widgets/meal/meal_grid.dart';
import '../../recipe/recipe_page.dart';

class DefaultRecipesSection extends StatelessWidget {
  final ApiService apiService;

  const DefaultRecipesSection({
    super.key,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Sample dishes you can make with chicken",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: FutureBuilder<ApiResponse<List<dynamic>>>(
            future: apiService.getMealsByCategory('Chicken'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingView();
              }
              if (snapshot.hasError || (snapshot.data?.error != null)) {
                return const ErrorView(
                  errString:
                      'Error loading sample dishes. Check your connection and try again',
                );
              }
              final meals = snapshot.data?.data ?? [];
              return MealGrid(
                meals: meals,
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
        ),
      ],
    );
  }
}
