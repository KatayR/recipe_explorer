import 'package:flutter/material.dart';
import '../../../constants/text_constants.dart';
import 'favorites_button.dart';

/// App name eyebrow + large headline, with the favorites button on the right.
class HomeHeader extends StatelessWidget {
  final String headline;

  const HomeHeader({super.key, this.headline = TextConstants.homeHeadline});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TextConstants.appTitle,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(headline, style: theme.textTheme.headlineSmall),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const FavoritesButton(),
      ],
    );
  }
}
