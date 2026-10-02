import 'package:flutter/material.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import 'package:recipe_explorer/constants/ui_constants.dart';
import '../../../widgets/section_header.dart';

/// Ingredient list in a bordered card: name on the left, measure on the right.
class RecipeIngredientsSection extends StatelessWidget {
  final List<String> ingredients;
  final List<String> measures;

  const RecipeIngredientsSection({
    super.key,
    required this.ingredients,
    required this.measures,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: TextConstants.ingredientsTitle,
          trailing: Text(
            TextConstants.itemCount(ingredients.length),
            style: theme.textTheme.labelMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              for (int index = 0; index < ingredients.length; index++) ...[
                if (index > 0) const Divider(indent: UIConstants.doublePadding),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.doublePadding,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          ingredients[index].trim(),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // API can return fewer measures than ingredients
                      Expanded(
                        flex: 2,
                        child: Text(
                          index < measures.length ? measures[index].trim() : '',
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
