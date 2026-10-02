import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constants/text_constants.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/meal/meal_image.dart';

/// Collapsing hero app bar for the recipe page.
///
/// Shows the meal photo full-bleed with round back/favorite buttons; once
/// [isCollapsed] flips, the title fades in and the status bar icons adapt.
class RecipeHeader extends StatelessWidget {
  final String mealId;
  final String imageUrl;
  final String title;
  final double expandedHeight;
  final RxBool isCollapsed;
  final bool Function() isFavorite;
  final VoidCallback onToggleFavorite;

  const RecipeHeader({
    super.key,
    required this.mealId,
    required this.imageUrl,
    required this.title,
    required this.expandedHeight,
    required this.isCollapsed,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collapsedOverlay = theme.brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;

    return Obx(() {
      final collapsed = isCollapsed.value;
      final favorite = isFavorite();

      return SliverAppBar(
        pinned: true,
        expandedHeight: expandedHeight,
        backgroundColor: theme.colorScheme.surface,
        // Light icons over the photo scrim, theme-appropriate once collapsed
        systemOverlayStyle: (collapsed ? collapsedOverlay : SystemUiOverlayStyle.light)
            .copyWith(statusBarColor: Colors.transparent),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: _HeaderButton(
            icon: Icons.arrow_back_rounded,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => Get.back(),
          ),
        ),
        title: AnimatedOpacity(
          opacity: collapsed ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        actions: [
          _HeaderButton(
            icon: favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: favorite ? AppTheme.favorite : null,
            tooltip: favorite
                ? TextConstants.removeFavoriteTooltip
                : TextConstants.addFavoriteTooltip,
            onPressed: onToggleFavorite,
          ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            fit: StackFit.expand,
            children: [
              MealImage(
                mealId: mealId,
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              // Top scrim keeps the status bar readable on bright photos
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.35],
                    colors: [Colors.black45, Colors.transparent],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Round translucent button that stays legible over photos and plain surfaces.
class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton.filled(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
        foregroundColor: color ?? colorScheme.onSurface,
      ),
      icon: Icon(icon),
    );
  }
}
