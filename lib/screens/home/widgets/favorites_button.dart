import 'package:flutter/material.dart';
import '../../../constants/text_constants.dart';
import '../../../constants/ui_constants.dart';
import '../../favorites/favorites_page.dart';

class FavoritesButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FavoritesButton({
    super.key,
    required this.onPressed,
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
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FavoritesPage(),
            ),
          ),
        ),
      ),
    );
  }
}
