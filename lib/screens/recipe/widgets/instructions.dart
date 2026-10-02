import 'package:flutter/material.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import 'package:recipe_explorer/constants/ui_constants.dart';
import '../../../utils/instruction_parser.dart';
import '../../../widgets/section_header.dart';

/// Instructions rendered as numbered steps (a single paragraph is shown without a number).
class RecipeInstructionsSection extends StatelessWidget {
  final String instructions;

  const RecipeInstructionsSection({
    super.key,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final steps = InstructionParser.parse(instructions);
    final numbered = steps.length > 1;
    final stepStyle = theme.textTheme.bodyLarge?.copyWith(height: 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: TextConstants.instructionsTitle,
          trailing: numbered
              ? Text(
                  TextConstants.stepCount(steps.length),
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                )
              : null,
        ),
        const SizedBox(height: UIConstants.defaultSpacing),
        for (int index = 0; index < steps.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (numbered) ...[
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(child: Text(steps[index], style: stepStyle)),
              ],
            ),
          ),
      ],
    );
  }
}
