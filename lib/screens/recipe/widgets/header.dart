import 'package:flutter/material.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/meal/meal_image.dart';

class RecipeHeader extends StatelessWidget {
  final String mealId;
  final String imageUrl;
  final Widget ingredientsSection;

  const RecipeHeader({
    super.key,
    required this.mealId,
    required this.imageUrl,
    required this.ingredientsSection,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: MealImage(
              mealId: mealId,
              imageUrl: imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          ingredientsSection,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: MealImage(
              mealId: mealId,
              imageUrl: imageUrl,
              height: 400,
              width: 400,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: ingredientsSection),
      ],
    );
  }
}
