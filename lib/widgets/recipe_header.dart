import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class RecipeHeader extends StatelessWidget {
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const RecipeHeader({
    required this.imageUrl,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        height: ResponsiveHelper.isMobile(context) ? 200 : 400,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
