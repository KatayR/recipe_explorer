import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'meal_image.dart';
import '../../constants/text_constants.dart';
import '../../constants/ui_constants.dart';
import '../../services/favorites_service.dart';
import '../../theme/app_theme.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final favoritesController = Get.find<FavoritesController>();
    final String? area = meal['strArea'];
    // Matches the info height reserved by ResponsiveHelper.mealGridDelegate
    final infoHeight =
        MediaQuery.textScalerOf(context).scale(UIConstants.mealCardInfoHeight);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  useCachedImage
                      ? MealImage(
                          mealId: meal['idMeal'],
                          imageUrl: meal['strMealThumb'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : _NetworkMealImage(url: meal['strMealThumb']),
                  // Small heart badge on recipes that are already saved
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Obx(() {
                      if (!favoritesController.isFavorite(meal['idMeal'])) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 16,
                          color: AppTheme.favorite,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: infoHeight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal['strMeal'],
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (area != null && area.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(UIConstants.pillRadius),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Text(
                          area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Network thumbnail that fades in over a neutral placeholder.
class _NetworkMealImage extends StatelessWidget {
  final String url;

  const _NetworkMealImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                color: colorScheme.onSurfaceVariant,
                size: UIConstants.smallIconSize + 4,
              ),
              const SizedBox(height: 4),
              Text(
                TextConstants.imageLoadError,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
