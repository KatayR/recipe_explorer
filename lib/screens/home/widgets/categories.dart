/// A widget that displays a section of categories, allowing users to select a category.
///
/// The [CategoriesSection] widget fetches categories from an API service and displays them
/// in a horizontal list. It handles loading and error states, and allows users to select
/// a category.
///
/// The [onCategorySelected] callback is triggered when a category is selected.
///
///
/// The [CategoriesSection] widget uses GetX reactive state management.
///

// Yes, this is a rather large snippet, but it's all related to the same widget.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../services/api_service.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/text_constants.dart';
import '../../../constants/ui_constants.dart';
import '../../../models/category_model.dart';
import '../../../utils/responsive_helper.dart';

class CategoriesSectionController extends GetxController {
  final ApiController _apiController = Get.find<ApiController>();

  var categories = <Category>[].obs;
  var isLoading = true.obs;
  var error = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  /// Loads categories from the API service.
  ///
  /// This method fetches categories from the API service and updates the reactive state
  /// accordingly. It handles loading and error states.
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      error.value = null;

      final response = await _apiController.getCategories();

      isLoading.value = false;
      if (response.error != null) {
        error.value = response.error;
      } else if (response.data != null) {
        categories.value =
            response.data!.map((json) => Category.fromJson(json)).toList();
      }
    } catch (e) {
      isLoading.value = false;
      error.value = 'Failed to load categories. Please check your connection.';
    }
  }
}

class CategoriesSection extends GetView<CategoriesSectionController> {
  /// Callback function triggered when a category is selected.
  final Function(String category) onCategorySelected;

  const CategoriesSection({
    super.key,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller only if not already created
    Get.lazyPut(() => CategoriesSectionController(), tag: 'categories');
    final controller = Get.find<CategoriesSectionController>(tag: 'categories');

    return Obx(() {
      if (controller.isLoading.value) {
        return const _CategoryListSkeleton();
      }

      if (controller.error.value != null) {
        return _CategoryError(onRetry: controller.loadCategories);
      }

      return CategoryList(
        categories: controller.categories,
        onCategorySelected: onCategorySelected,
      );
    });
  }
}

/// Controller for the CategoryList widget that manages scroll state.
class CategoryListController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final showLeftArrow = false.obs;
  final showRightArrow = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_updateArrows);
  }
  
  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
  
  /// Updates the visibility of the scroll arrows based on the scroll position.
  void _updateArrows() {
    showLeftArrow.value = scrollController.position.pixels > 0;
    showRightArrow.value = scrollController.position.pixels < scrollController.position.maxScrollExtent;
  }
  
  /// Scrolls the list view in the specified direction.
  ///
  /// The [direction] parameter specifies the direction to scroll.
  /// A positive value scrolls to the right, and a negative value scrolls to the left.
  void scroll(double direction) {
    scrollController.animateTo(
      scrollController.offset + (direction * AppConstants.categoryScrollOffset),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

/// A widget that displays a list of categories in a horizontal scrollable view.
///
/// The [CategoryList] widget displays a list of categories and allows users to
/// select a category. It includes scroll arrows for navigating the list.
///
/// The [categories] parameter specifies the list of categories to display.
/// The [onCategorySelected] callback is triggered when a category is selected.
class CategoryList extends GetView<CategoryListController> {
  /// List of categories to display.
  final List<Category> categories;

  /// Callback function triggered when a category is selected.
  final Function(String category) onCategorySelected;
  
  final String? controllerTag;

  /// Creates a [CategoryList] widget.
  const CategoryList({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    this.controllerTag,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller with unique tag to avoid conflicts
    final uniqueTag = controllerTag ?? UniqueKey().toString();
    Get.put(CategoryListController(), tag: uniqueTag);
    final controller = Get.find<CategoryListController>(tag: uniqueTag);
    
    final height = _CategoryMetrics.of(context).listHeight;
    // Scroll arrows only help pointer users on wide layouts; touch users swipe
    final showArrows = !ResponsiveHelper.isMobile(context);

    return SizedBox(
      height: height,
      child: Obx(() => Stack(
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.trackpad,
              },
              scrollbars: false,
            ),
            child: ListView.builder(
              controller: controller.scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryItem(
                  category: category,
                  onTap: () => onCategorySelected(category.strCategory),
                );
              },
            ),
          ),
          if (showArrows && controller.showLeftArrow.value)
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: _ScrollArrow(
                direction: -1,
                onTap: () => controller.scroll(-1),
              ),
            ),
          if (showArrows && controller.showRightArrow.value)
            Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: _ScrollArrow(
                direction: 1,
                onTap: () => controller.scroll(1),
              ),
            ),
        ],
      )),
    );
  }
}

/// A widget that displays a scroll arrow for navigating a list view.
///
/// The [_ScrollArrow] widget displays a scroll arrow and handles tap events
/// to scroll the list view in the specified direction.
///
/// The [direction] parameter specifies the direction to scroll.
/// A positive value scrolls to the right, and a negative value scrolls to the left.
/// The [onTap] callback is triggered when the arrow is tapped.
class _ScrollArrow extends StatelessWidget {
  /// Direction to scroll when the arrow is tapped.
  final int direction;

  /// Callback function triggered when the arrow is tapped.
  final VoidCallback onTap;

  /// Creates a [_ScrollArrow] widget.
  const _ScrollArrow({
    required this.direction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: IconButton.filledTonal(
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.95),
          foregroundColor: colorScheme.onSurface,
        ),
        icon: Icon(
          direction == -1 ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
        ),
      ),
    );
  }
}

/// A widget that displays a single category item.
///
/// The [CategoryItem] widget displays a category item with an image and text.
/// It handles tap events to trigger the [onTap] callback.
///
/// The [category] parameter specifies the category to display.
/// The [onTap] callback is triggered when the category item is tapped.
class CategoryItem extends StatelessWidget {
  final Category category;

  /// Callback function triggered when the category item is tapped.
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = _CategoryMetrics.of(context);

    return SizedBox(
      width: metrics.itemWidth,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.tileRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              _CategoryTile(
                size: metrics.tileSize,
                child: Image.network(
                  category.strCategoryThumb,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.restaurant_menu_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.strCategory,
                style: theme.textTheme.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded, bordered square that frames a category thumbnail (or a placeholder).
class _CategoryTile extends StatelessWidget {
  final double size;
  final Widget? child;

  const _CategoryTile({required this.size, this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.brightness == Brightness.light
            ? colorScheme.surfaceContainerLowest
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(UIConstants.tileRadius),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: child,
    );
  }
}

/// Sizes of the category strip for the current screen size and text scale.
class _CategoryMetrics {
  final double tileSize;
  final double itemWidth;
  final double listHeight;

  const _CategoryMetrics(this.tileSize, this.itemWidth, this.listHeight);

  factory _CategoryMetrics.of(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final tileSize = isDesktop
        ? UIConstants.categoryTileSizeDesktop
        : UIConstants.categoryTileSize;
    final labelHeight = MediaQuery.textScalerOf(context).scale(20);
    return _CategoryMetrics(
      tileSize,
      isDesktop ? UIConstants.categoryItemWidthDesktop : UIConstants.categoryItemWidth,
      // vertical padding + tile + gap + label
      8 + tileSize + 8 + labelHeight,
    );
  }
}

/// Placeholder tiles shown while categories load.
class _CategoryListSkeleton extends StatelessWidget {
  const _CategoryListSkeleton();

  @override
  Widget build(BuildContext context) {
    final metrics = _CategoryMetrics.of(context);
    final placeholder =
        Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);

    return SizedBox(
      height: metrics.listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 8,
        itemBuilder: (context, index) => SizedBox(
          width: metrics.itemWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _CategoryTile(size: metrics.tileSize),
                const SizedBox(height: 8),
                Container(
                  width: metrics.tileSize * 0.7,
                  height: 10,
                  decoration: BoxDecoration(
                    color: placeholder,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact inline error for the categories strip.
class _CategoryError extends StatelessWidget {
  final VoidCallback onRetry;

  const _CategoryError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: theme.colorScheme.error,
            size: UIConstants.smallIconSize,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              TextConstants.categoriesLoadError,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(TextConstants.tryAgainButton),
          ),
        ],
      ),
    );
  }
}
