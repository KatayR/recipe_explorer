import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/text_constants.dart';
import '../../../constants/ui_constants.dart';
import '../../../routes/app_routes.dart';

class FavoritesButton extends StatelessWidget {
  const FavoritesButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: TextConstants.favoritesTooltip,
      child: Material(
        color: Colors.red.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: UIConstants.circularBorderRadious,
        ),
        elevation: 2,
        child: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => Get.toNamed(AppRoutes.favorites),
        ),
      ),
    );
  }
}
