import 'dart:ui';

import 'package:flutter/material.dart';
import '../screens/home_page.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.initializeFfi();
  runApp(const RecipeExplorer());
}

class RecipeExplorer extends StatelessWidget {
  const RecipeExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
        },
      ),
      title: 'Recipe Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
