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
                return ErrorView(
                    errString: snapshot.data?.error ?? 'Error loading recipes');
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
