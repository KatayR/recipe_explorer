import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/text_constants.dart';
import '../../services/image_cache.dart';

class MealImageController extends GetxController {
  final ImageCacheService _imageCacheService = Get.find<ImageCacheService>();
  final cachedPath = Rx<String?>(null);
  final isLoading = true.obs;
  
  /// Loads the image either from cache or by downloading it.
  Future<void> loadImage(String mealId, String imageUrl) async {
    try {
      // Checking if image is already cached
      final existingPath = await _imageCacheService.getCachedImagePath(mealId);
      final file = File(existingPath);

      if (await file.exists()) {
        cachedPath.value = existingPath;
        isLoading.value = false;
        return;
      }

      // If not cached, downloading and caching it
      final path = await _imageCacheService.cacheImage(mealId, imageUrl);
      cachedPath.value = path;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
    }
  }
}

class MealImage extends GetView<MealImageController> {
  final String mealId;
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? controllerTag;

  const MealImage({
    super.key,
    required this.mealId,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.controllerTag,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller with unique tag to avoid conflicts
    final uniqueTag = controllerTag ?? '$mealId-${imageUrl.hashCode}';
    Get.put(MealImageController(), tag: uniqueTag);
    final controller = Get.find<MealImageController>(tag: uniqueTag);
    
    // Load image when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadImage(mealId, imageUrl);
    });
    
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (controller.isLoading.value) {
        // Neutral placeholder instead of a spinner, matching the grid cards
        return Container(
          width: width,
          height: height,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        );
      }

      if (controller.cachedPath.value != null) {
        return Image.file(
          File(controller.cachedPath.value!),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(context),
        );
      }

      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(context),
      );
    });
  }

  /// Builds a widget to display when an error occurs while loading the image.
  Widget _buildErrorWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            TextConstants.imageLoadError,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
