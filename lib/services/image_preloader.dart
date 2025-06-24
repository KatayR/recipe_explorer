import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImagePreloaderService extends GetxService {

  /// Maximum number of images to keep in cache (LRU eviction)
  static const int maxCacheSize = 50;
  
  /// Maximum estimated memory usage in MB (rough estimate: 500KB per image)
  static const double maxMemoryMB = 25.0;
  
  /// LRU cache implementation - LinkedHashMap maintains insertion order
  /// Key: image URL, Value: timestamp when added
  final Map<String, DateTime> _lruCache = <String, DateTime>{};

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
  /// Checks the internal cache first to avoid redundant network requests for
  /// images that have already been preloaded in this session. Uses Flutter's
  /// [precacheImage] to load the image from [url] and store it in memory.
  /// 
  /// Returns a [Future] that completes when the image is cached or fails.
  /// Enforces LRU cache size and memory limits
  void _evictIfNeeded() {
    while (_lruCache.length >= maxCacheSize) {
      // Remove oldest entry (first in LinkedHashMap)
      final oldestUrl = _lruCache.keys.first;
      _lruCache.remove(oldestUrl);
      
      // Also evict from Flutter's image cache
      final imageProvider = NetworkImage(oldestUrl);
      imageProvider.evict();
      
      debugPrint(' 🗑️ Evicted oldest cached image: $oldestUrl');
    }
    
    // Rough memory check (assuming ~500KB per image)
    final estimatedMemoryMB = _lruCache.length * 0.5;
    if (estimatedMemoryMB > maxMemoryMB) {
      debugPrint(' ⚠️ Estimated memory usage: ${estimatedMemoryMB.toStringAsFixed(1)}MB exceeds limit of ${maxMemoryMB}MB');
    }
  }

  Future<void> preloadNetworkImage(String url, BuildContext context) async {
    // Skip if already preloaded in this session
    if (_lruCache.containsKey(url)) {
      // Move to end (mark as recently used)
      final timestamp = _lruCache.remove(url)!;
      _lruCache[url] = timestamp;
      debugPrint(' ⚡ Image already cached, marking as recent: $url');
      return;
    }

    debugPrint(' 🔄 Attempting to preload image: $url');
    try {
      await precacheImage(NetworkImage(url), context);
      
      // Add to LRU cache with current timestamp
      _lruCache[url] = DateTime.now();
      
      // Enforce cache size limits
      _evictIfNeeded();
      
      debugPrint(' ✅ Successfully preloaded image: $url (cache: ${_lruCache.length}/$maxCacheSize)');
    } catch (e) {
      debugPrint(' ❌ Failed to precache image: $url, Error: $e');
    }
  }

  /// Preloads multiple network images sequentially with throttling.
  /// 
  /// Takes a list of image [urls] and preloads them one by one with a 75ms
  /// delay between requests to avoid overwhelming the server. Automatically
  /// skips URLs that have already been cached in this session.
  /// 
  /// This method is used for both initial batch preloading and progressive
  /// loading during scroll.
  Future<void> preloadNetworkImages(List<String> urls, BuildContext context) async {
    final uncachedUrls = urls.where((url) => !_lruCache.containsKey(url)).toList();
    final skippedCount = urls.length - uncachedUrls.length;
    
    debugPrint('Starting to preload ${urls.length} images ($skippedCount already cached, ${uncachedUrls.length} new)');

    for (int i = 0; i < uncachedUrls.length; i++) {
      final url = uncachedUrls[i];
      
      // Check if context is still mounted before using it
      if (!context.mounted) return;
      
      await preloadNetworkImage(url, context);

      // Add a small delay between each request to avoid overwhelming the server
      if (i < uncachedUrls.length - 1) {
        await Future.delayed(const Duration(milliseconds: 75));
      }
    }

    debugPrint('Finished preloading batch: ${uncachedUrls.length} new images cached, $skippedCount skipped');
  }

  /// Checks whether an image URL has already been preloaded in this session.
  /// 
  /// Returns `true` if the image was successfully cached previously,
  /// `false` if it hasn't been preloaded yet.
  bool isImageCached(String url) {
    return _lruCache.containsKey(url);
  }

  /// Gets the number of unique images that have been preloaded in this session.
  int get cachedImageCount => _lruCache.length;
  
  /// Gets the estimated memory usage in MB (rough calculation)
  double get estimatedMemoryMB => _lruCache.length * 0.5;
  
  /// Gets cache usage as a percentage of maximum
  double get cacheUsagePercent => (_lruCache.length / maxCacheSize) * 100;

  /// Clears the LRU cache and evicts all images from Flutter's cache.
  /// 
  /// This clears both our tracking and Flutter's actual image cache.
  /// Use sparingly, typically only needed for testing or memory pressure.
  void clearCache() {
    // Evict all images from Flutter's cache
    for (final url in _lruCache.keys) {
      final imageProvider = NetworkImage(url);
      imageProvider.evict();
    }
    
    _lruCache.clear();
    debugPrint('🗑️ Cleared LRU cache and evicted all images from Flutter cache');
  }
  
  /// Provides cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedImages': _lruCache.length,
      'maxCacheSize': maxCacheSize,
      'usagePercent': cacheUsagePercent.toStringAsFixed(1),
      'estimatedMemoryMB': estimatedMemoryMB.toStringAsFixed(1),
      'maxMemoryMB': maxMemoryMB,
    };
  }
}
