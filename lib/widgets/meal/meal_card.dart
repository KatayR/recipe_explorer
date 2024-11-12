import 'package:flutter/material.dart';
import 'meal_image.dart';

class MealCard extends StatelessWidget {
  final dynamic meal;
  final VoidCallback onTap;
  final bool useCachedImage;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
    this.useCachedImage = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: useCachedImage
                  ? MealImage(
                      mealId: meal['idMeal'],
                      imageUrl: meal['strMealThumb'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      meal['strMealThumb'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                meal['strMeal'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
