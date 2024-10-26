import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';
import '../common/meal_image.dart';

class RecipeHeader extends StatelessWidget {
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final String mealId;

  const RecipeHeader({
    super.key,
    required this.imageUrl,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.mealId,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: MealImage(
        mealId: mealId,
        imageUrl: imageUrl,
        height: ResponsiveHelper.isMobile(context) ? 200 : 400,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
