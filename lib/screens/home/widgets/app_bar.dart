import 'package:flutter/material.dart';
import '../../favorites/favorites_page.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Recipe Explorer'),
      actions: [
        TextButton(
          child: const Text('💕', style: TextStyle(fontSize: 22)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesPage()),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
