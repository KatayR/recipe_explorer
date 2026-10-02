import 'package:flutter/material.dart';
import 'package:recipe_explorer/constants/ui_constants.dart';

/// Outlined chips summarizing category and cuisine.
class RecipeMetadataSection extends StatelessWidget {
  final String category;
  final String area;

  const RecipeMetadataSection({
    super.key,
    required this.category,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.primary;

    Widget chip(IconData icon, String label) => Chip(
          avatar: Icon(icon, size: 18, color: iconColor),
          label: Text(label),
          visualDensity: VisualDensity.compact,
        );

    return Wrap(
      spacing: UIConstants.defaultPadding,
      runSpacing: UIConstants.defaultPadding,
      children: [
        if (category.isNotEmpty) chip(Icons.restaurant_menu_rounded, category),
        if (area.isNotEmpty) chip(Icons.public_rounded, area),
      ],
    );
  }
}
