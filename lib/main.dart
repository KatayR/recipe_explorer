import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import 'screens/home/home_page.dart';
import 'services/storage_service.dart';
import 'services/connectivity_service.dart';
import 'services/image_cache.dart';
import 'services/image_preloader.dart';
import 'services/api_service.dart';
import 'services/favorites_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized before using platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the FFI database
  await StorageService.initializeFfi();
  
  // Initialize GetX services
  Get.put(StorageService());
  Get.put(ConnectivityService());
  Get.put(ImageCacheService());
  Get.put(ImagePreloaderService());
  Get.put(ApiController());
  Get.put(FavoritesController());
  
  runApp(const RecipeExplorer());
}

class RecipeExplorer extends StatelessWidget {
  const RecipeExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // Configure scroll behavior to support multiple input devices
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
        },
      ),
      title: TextConstants.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
