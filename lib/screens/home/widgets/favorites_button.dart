import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/text_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../services/favorites_service.dart';

/// Outlined heart button with a live badge showing how many recipes are saved.
class FavoritesButton extends StatelessWidget {
  const FavoritesButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesController = Get.find<FavoritesController>();

    return Obx(() {
      final count = favoritesController.favoriteIds.length;
      return IconButton.outlined(
        tooltip: TextConstants.favoritesTooltip,
        onPressed: () => Get.toNamed(AppRoutes.favorites),
        style: IconButton.styleFrom(
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        icon: Badge.count(
          count: count,
          isLabelVisible: count > 0,
          child: const Icon(Icons.favorite_border_rounded),
        ),
      );
    });
  }
}
