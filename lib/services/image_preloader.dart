import 'package:flutter/material.dart';

class ImagePreloaderService {
  static final ImagePreloaderService _instance = ImagePreloaderService._internal();
  factory ImagePreloaderService() => _instance;
  ImagePreloaderService._internal();

  /// Standard initial preload count applied consistently across all screens.
  static const int standardPreloadCount = 15;

  /// Progressive preloading algorithm documentation.
  /// 
  /// This system uses scroll-based progressive loading to eliminate blank image
  /// blocks during fast scrolling while maintaining memory efficiency.
  /// 
  /// ## Algorithm Steps:
  /// 
  /// ### 1. GET SCROLL POSITION
  /// - `scrollOffset`: Current scroll position in pixels from top
  /// - `maxScrollExtent`: Total scrollable distance in pixels
  /// 
  /// ### 2. CONVERT TO PERCENTAGE
  /// - `scrollPercentage = scrollOffset / maxScrollExtent`
  /// - Examples: 0.0 = top, 0.5 = middle, 1.0 = bottom
  /// 
  /// ### 3. MAP TO ITEM INDEX
  /// - `currentItemIndex = (scrollPercentage * totalItems).floor()`
  /// - Examples with 36 items:
  ///   - scrollPercentage 0.0 → viewing item 0
  ///   - scrollPercentage 0.5 → viewing item 18
  ///   - scrollPercentage 0.8 → viewing item 28
  /// 
  /// ### 4. CALCULATE 20-AHEAD TARGET
  /// - `targetPreloadCount = (currentItemIndex + 20).clamp(0, totalItems)`
  /// - Examples with 36 items:
  ///   - viewing item 0 → preload to item 20
  ///   - viewing item 10 → preload to item 30
  ///   - viewing item 25 → preload to item 36 (clamped)
  /// 
  /// ### 5. ENFORCE 15-ITEM MINIMUM
  /// For early scrolling in long lists:
  /// - `proposedTarget = max(targetPreloadCount, 15)`
  /// - Examples:
  ///   - 100-item list, viewing item 0: target=20, keep 20 (≥15)
  ///   - 100-item list, viewing item 2: target=22, keep 22 (≥15)
  ///   - Short lists automatically clamped to list length anyway
  /// 
  /// ### 6. END-OF-LIST OPTIMIZATION
  /// If proposedTarget would leave ≤5 items remaining, preload everything:
  /// - Examples with 36 items:
  ///   - viewing item 10: target=30, remaining=6, preload to 30 (6>5)
  ///   - viewing item 15: target=35, remaining=1, preload all 36 (1≤5)
  ///   - viewing item 20: target=36, remaining=0, already at end
  /// 
  /// ### 7. SPAM PREVENTION
  /// Only trigger if we need ≥5 more items than currently preloaded.

  /// Preloads a single network image into Flutter's image cache.
  /// 
  /// Uses Flutter's [precacheImage] to load the image from [url] and store it
  /// in memory for instant display when needed.
  /// 
  /// Returns a [Future] that completes when the image is cached or fails.
  Future<void> preloadNetworkImage(String url, BuildContext context) async {
    debugPrint(' 🔄 Attempting to preload image: $url');
    try {
      await precacheImage(NetworkImage(url), context);
      debugPrint(' ✅ Successfully preloaded image: $url');
    } catch (e) {
      debugPrint('Failed to precache image: $url, Error: $e');
    }
  }

  /// Preloads multiple network images sequentially with throttling.
  /// 
  /// Takes a list of image [urls] and preloads them one by one with a 75ms
  /// delay between requests to avoid overwhelming the server.
  /// 
  /// This method is used for both initial batch preloading and progressive
  /// loading during scroll.
  Future<void> preloadNetworkImages(List<String> urls, BuildContext context) async {
    debugPrint('Starting to preload ${urls.length} images');

    for (int i = 0; i < urls.length; i++) {
      final url = urls[i];
      await preloadNetworkImage(url, context);

      // Add a small delay between each request to avoid overwhelming the server
      if (i < urls.length - 1) {
        await Future.delayed(const Duration(milliseconds: 75));
      }
    }

    debugPrint('Finished preloading all images');
  }
}
