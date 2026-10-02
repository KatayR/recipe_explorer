import 'package:flutter/material.dart';
import 'package:recipe_explorer/constants/ui_constants.dart';
import '../../../constants/text_constants.dart';
import 'home_header.dart';

/// Home header shown while offline; keeps the favorites entry point reachable.
class OfflineAppBar extends StatelessWidget {
  const OfflineAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        UIConstants.pagePadding,
        UIConstants.doublePadding,
        UIConstants.pagePadding,
        0,
      ),
      child: HomeHeader(headline: TextConstants.offlineHeadline),
    );
  }
}
