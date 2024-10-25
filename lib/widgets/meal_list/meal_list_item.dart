import 'package:flutter/material.dart';

class MealListItem extends StatelessWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onTap;

  const MealListItem({
    super.key,
    required this.meal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    print('Building MealListItem: ${meal['strMeal']}');

    final mealName = meal['strMeal'];
    final mealThumb = meal['strMealThumb'];

    if (mealName == null) {
      print('Warning: MealListItem has null meal name');
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: mealThumb != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  mealThumb,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image for $mealName: $error');
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              )
            : Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.no_food),
              ),
        title: Text(
          mealName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
