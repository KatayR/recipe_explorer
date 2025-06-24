import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/text_constants.dart';
import '../../services/image_cache.dart';
import '../loading/loading_view.dart';

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

class MealImage extends StatefulWidget {
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
  State<MealImage> createState() => _MealImageState();
}

class _MealImageState extends State<MealImage> {
  late String uniqueTag;
  late MealImageController controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller with unique tag to avoid conflicts
    uniqueTag = widget.controllerTag ?? '${widget.mealId}-${widget.imageUrl.hashCode}';
    Get.put(MealImageController(), tag: uniqueTag);
    controller = Get.find<MealImageController>(tag: uniqueTag);
    
    // Load image when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadImage(widget.mealId, widget.imageUrl);
    });
  }

  @override
  void dispose() {
    // Properly dispose of controller when widget is destroyed
    Get.delete<MealImageController>(tag: uniqueTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: const LoadingView(),
        );
      }

      if (controller.cachedPath.value != null) {
        return Image.file(
          File(controller.cachedPath.value!),
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      }

      return Image.network(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    });
  }

  /// Builds a widget to display when an error occurs while loading the image.
  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(height: 8),
          Text(TextConstants.imageLoadError),
        ],
      ),
    );
  }
}