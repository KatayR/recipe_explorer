import 'package:flutter/material.dart';

class MealListItem extends StatelessWidget {
  final dynamic meal;
  final VoidCallback onTap;

  const MealListItem({
    super.key,
    required this.meal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            meal['strMealThumb'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(meal['strMeal']),
        onTap: onTap,
      ),
    );
  }
}
