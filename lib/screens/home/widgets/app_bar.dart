import 'package:flutter/material.dart';
import 'package:recipe_explorer/constants/ui_constants.dart';
import '../../../constants/text_constants.dart';
import '../../favorites/favorites_page.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      title: const Text(TextConstants.appTitle),
      actions: [
        Tooltip(
          message: "Favorites (✨Offline First✨)",
          child: TextButton(
            child: const Text(TextConstants.addToFavoritesButton,
                style: TextStyle(fontSize: UIConstants.titleFontSize)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesPage()),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
