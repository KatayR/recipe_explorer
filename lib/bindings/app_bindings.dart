import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../services/connectivity_service.dart';
import '../services/image_cache.dart';
import '../services/image_preloader.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

/// GetX bindings for dependency injection
/// 
/// This class handles the initialization of all core services when the app starts.
/// Using bindings provides better organization and lifecycle management compared
/// to manual Get.put() calls in main.dart.
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Core services - initialized as singletons
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<ImageCacheService>(ImageCacheService(), permanent: true);
    Get.put<ImagePreloaderService>(ImagePreloaderService(), permanent: true);
    
    // API and business logic services
    Get.put<ApiController>(ApiController(), permanent: true);
    Get.put<FavoritesController>(FavoritesController(), permanent: true);
  }
}

/// Bindings for the home page and its dependencies
class HomeBindings extends Bindings {
  @override
  void dependencies() {
    // Home page specific controllers can be added here
    // For now, all controllers are globally available through AppBindings
  }
}

/// Bindings for the results page and its dependencies
class ResultsBindings extends Bindings {
  @override
  void dependencies() {
    // Results page specific controllers can be added here
    // For now, all controllers are globally available through AppBindings
  }
}

/// Bindings for the recipe page and its dependencies
class RecipeBindings extends Bindings {
  @override
  void dependencies() {
    // Recipe page specific controllers can be added here
    // For now, all controllers are globally available through AppBindings
  }
}

/// Bindings for the favorites page and its dependencies
class FavoritesBindings extends Bindings {
  @override
  void dependencies() {
    // Favorites page specific controllers can be added here
    // For now, all controllers are globally available through AppBindings
  }
}