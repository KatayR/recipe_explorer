import 'package:flutter/material.dart';
import 'package:recipe_explorer/constants/ui_constants.dart';
import '../../../constants/text_constants.dart';
import 'favorites_button.dart';

class OfflineAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OfflineAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: UIConstants.offlineAppBarHeight,
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: Text(
              TextConstants.offlineFavoritesHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: UIConstants.titleFontSize,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
          ),
          const FavoritesButton(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
