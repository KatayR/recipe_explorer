import 'package:flutter/material.dart';
import 'image_preloader.dart';

/// Service responsible for managing scroll-based progressive image preloading.
/// 
/// This service encapsulates all the logic for determining when and how many
/// images to preload based on scroll position, separating this concern from
/// the UI widgets.
/// 
/// ## Usage
/// ```dart
/// final scrollPreloader = ScrollPreloader(
///   imageUrls: mealImageUrls,
///   imagePreloader: ImagePreloaderService(),
/// );
/// 
/// // In initState
/// scrollPreloader.initialize(context);
/// scrollController.addListener(() => scrollPreloader.onScroll(scrollController));
/// 
/// // In dispose
/// scrollPreloader.dispose();
/// ```
class ScrollPreloader {
  final List<String> _imageUrls;
  final ImagePreloaderService _imagePreloader;
  
  BuildContext? _context;
  int _preloadedCount = 0;
  bool _isPreloading = false;
  bool _isInitialized = false;

  ScrollPreloader({
    required List<String> imageUrls,
    ImagePreloaderService? imagePreloader,
  }) : _imageUrls = imageUrls,
       _imagePreloader = imagePreloader ?? ImagePreloaderService();

  /// Gets the current number of images that have been preloaded.
  int get preloadedCount => _preloadedCount;

  /// Gets the total number of images available for preloading.
  int get totalImageCount => _imageUrls.length;

  /// Gets whether the preloader is currently loading images.
  bool get isPreloading => _isPreloading;

  /// Initializes the scroll preloader and performs initial batch preloading.
  /// 
  /// Must be called with a valid [BuildContext] before using [onScroll].
  /// Preloads the first [ImagePreloaderService.standardPreloadCount] images.
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;
    
    _context = context;
    await _preloadInitialBatch();
    _isInitialized = true;
  }

  /// Handles scroll events and triggers progressive preloading when needed.
  /// 
  /// Should be called from a scroll listener with the current [ScrollController].
  /// Implements the 7-step progressive preloading algorithm documented in
  /// [ImagePreloaderService].
  void onScroll(ScrollController scrollController) {
    if (!_isInitialized || _context == null || _imageUrls.isEmpty || _isPreloading) {
      return;
    }

    final scrollData = _calculateScrollData(scrollController);
    final preloadTarget = _calculatePreloadTarget(scrollData);
    
    if (_shouldTriggerPreload(preloadTarget)) {
      _preloadMoreImages(preloadTarget);
    }
  }

  /// Updates the image URLs list (useful when data changes).
  /// 
  /// Resets preloading state and reinitializes if context is available.
  Future<void> updateImageUrls(List<String> newImageUrls) async {
    _imageUrls.clear();
    _imageUrls.addAll(newImageUrls);
    _preloadedCount = 0;
    _isPreloading = false;
    
    if (_context != null) {
      await _preloadInitialBatch();
    }
  }

  /// Cleans up resources and should be called in widget dispose.
  void dispose() {
    _context = null;
    _isInitialized = false;
  }

  /// Calculates scroll-related data needed for preload decisions.
  _ScrollData _calculateScrollData(ScrollController scrollController) {
    final scrollOffset = scrollController.offset;
    final maxScrollExtent = scrollController.position.maxScrollExtent;
    
    final scrollPercentage = maxScrollExtent > 0 ? scrollOffset / maxScrollExtent : 0.0;
    final currentItemIndex = (scrollPercentage * _imageUrls.length).floor();
    
    return _ScrollData(
      scrollPercentage: scrollPercentage,
      currentItemIndex: currentItemIndex,
    );
  }

  /// Calculates the target number of images to preload based on scroll position.
  int _calculatePreloadTarget(_ScrollData scrollData) {
    // Step 4: Calculate 20-ahead target
    final targetPreloadCount = (scrollData.currentItemIndex + 20).clamp(0, _imageUrls.length);
    
    // Step 5: Enforce 15-item minimum for early scrolling in long lists
    final proposedTarget = targetPreloadCount < ImagePreloaderService.standardPreloadCount 
        ? ImagePreloaderService.standardPreloadCount 
        : targetPreloadCount;
    
    // Step 6: End-of-list optimization
    final remainingAfterProposed = _imageUrls.length - proposedTarget;
    final shouldPreloadAll = remainingAfterProposed <= 5;
    
    return shouldPreloadAll ? _imageUrls.length : proposedTarget;
  }

  /// Determines whether preloading should be triggered based on current state.
  bool _shouldTriggerPreload(int targetCount) {
    final currentRemaining = _imageUrls.length - _preloadedCount;
    
    // Don't preload if no items remaining or already at target
    if (currentRemaining <= 0 || targetCount <= _preloadedCount) {
      return false;
    }
    
    // If 5 or fewer items remaining, preload all
    if (currentRemaining <= 5) {
      return true;
    }
    
    // Step 7: Spam prevention - only trigger if we need ≥5 more items
    return targetCount > _preloadedCount + 5;
  }

  /// Preloads the initial batch of images on service initialization.
  Future<void> _preloadInitialBatch() async {
    if (_imageUrls.isEmpty || _context == null) return;

    final imagesToPreload = _imageUrls
        .take(ImagePreloaderService.standardPreloadCount)
        .where((url) => url.isNotEmpty)
        .toList();
    
    if (imagesToPreload.isNotEmpty) {
      debugPrint('ScrollPreloader: Starting initial preload of ${imagesToPreload.length} images');
      
      await _imagePreloader.preloadNetworkImages(imagesToPreload, _context!);
      _preloadedCount = imagesToPreload.length;
      
      debugPrint('ScrollPreloader: Initial preload completed - $_preloadedCount/${_imageUrls.length} images cached');
    }
  }

  /// Preloads additional images up to the specified target count.
  Future<void> _preloadMoreImages(int targetCount) async {
    if (targetCount <= _preloadedCount || _context == null || _isPreloading) return;
    
    _isPreloading = true;
    
    try {
      final newImagesToPreload = _imageUrls
          .skip(_preloadedCount)
          .take(targetCount - _preloadedCount)
          .where((url) => url.isNotEmpty)
          .toList();
      
      if (newImagesToPreload.isNotEmpty) {
        debugPrint('ScrollPreloader: Progressive preload ${newImagesToPreload.length} more images (${_preloadedCount + 1} to $targetCount)');
        
        await _imagePreloader.preloadNetworkImages(newImagesToPreload, _context!);
        _preloadedCount = targetCount;
        
        debugPrint('ScrollPreloader: Now have $_preloadedCount/${_imageUrls.length} images preloaded');
      }
    } finally {
      _isPreloading = false;
    }
  }
}

/// Internal data class for scroll calculations.
class _ScrollData {
  final double scrollPercentage;
  final int currentItemIndex;

  _ScrollData({
    required this.scrollPercentage,
    required this.currentItemIndex,
  });
}