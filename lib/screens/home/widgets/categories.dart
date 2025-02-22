/// A widget that displays a section of categories, allowing users to select a category.
///
/// The [CategoriesSection] widget fetches categories from an API service and displays them
/// in a horizontal list. It handles loading and error states, and allows users to select
/// a category.
///
/// The [onCategorySelected] callback is triggered when a category is selected.
///
/// The [apiService] parameter can be used to provide a custom API service for fetching
/// categories. If not provided, a default [ApiService] instance is used.
///
/// The [CategoriesSection] widget is stateful and manages its own state, including
/// loading, error, and category data.
///

// Yes, this is a rather large snippet, but it's all related to the same widget.

import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../widgets/loading/loading_view.dart';
import '../../../widgets/error/error_view.dart';
import '../../../services/api_service.dart';
import '../../../models/category_model.dart';
import '../../../utils/responsive_helper.dart';

class CategoriesSection extends StatefulWidget {
  /// Callback function triggered when a category is selected.
  final Function(String category) onCategorySelected;

  final ApiService? apiService;

  const CategoriesSection({
    super.key,
    required this.onCategorySelected,
    this.apiService,
  });

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  /// API service for fetching categories.
  final ApiService _apiService;

  /// List of categories fetched from the API.
  List<Category> _categories = [];

  /// Indicates whether the categories are currently being loaded.
  bool _isLoading = true;

  /// Error message, if any, encountered while loading categories.
  String? _error;

  /// Initializes the state of the [CategoriesSection] widget.
  _CategoriesSectionState() : _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  /// Loads categories from the API service.
  ///
  /// This method fetches categories from the API service and updates the state
  /// accordingly. It handles loading and error states.
  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiService.getCategories();

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response.error != null) {
            _error = response.error;
          } else if (response.data != null) {
            _categories =
                response.data!.map((json) => Category.fromJson(json)).toList();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load categories. Please check your connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: LoadingView()),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 120,
        child: ErrorView(
          errString: _error!,
          onRetry: _loadCategories,
        ),
      );
    }

    return CategoryList(
      categories: _categories,
      onCategorySelected: widget.onCategorySelected,
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
class CategoryList extends StatefulWidget {
  /// List of categories to display.
  final List<Category> categories;

  /// Callback function triggered when a category is selected.
  final Function(String category) onCategorySelected;

  /// Creates a [CategoryList] widget.
  const CategoryList({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  /// Scroll controller for the horizontal list view.
  final ScrollController _scrollController = ScrollController();

  /// Indicates whether the left scroll arrow should be shown.
  bool _showLeftArrow = false;

  /// Indicates whether the right scroll arrow should be shown.
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrows);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Updates the visibility of the scroll arrows based on the scroll position.
  void _updateArrows() {
    setState(() {
      _showLeftArrow = _scrollController.position.pixels > 0;
      _showRightArrow = _scrollController.position.pixels <
          _scrollController.position.maxScrollExtent;
    });
  }

  /// Scrolls the list view in the specified direction.
  ///
  /// The [direction] parameter specifies the direction to scroll.
  /// A positive value scrolls to the right, and a negative value scrolls to the left.
  void _scroll(double direction) {
    _scrollController.animateTo(
      _scrollController.offset + (direction * 200),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Determines the height based on the device type.
    /// If the device is mobile, the height is set to 100.0.
    /// Otherwise, the height is set to 120.0.
    final height = ResponsiveHelper.isMobile(context) ? 100.0 : 120.0;

    return MouseRegion(
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.trackpad,
                },
                scrollbars: true,
              ),
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  final category = widget.categories[index];
                  return CategoryItem(
                    category: category,
                    onTap: () =>
                        widget.onCategorySelected(category.strCategory),
                  );
                },
              ),
            ),
            if (_showLeftArrow)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: _ScrollArrow(
                  direction: -1,
                  onTap: () => _scroll(-1),
                ),
              ),
            if (_showRightArrow)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: _ScrollArrow(
                  direction: 1,
                  onTap: () => _scroll(1),
                ),
              ),
          ],
        ),
      ),
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: direction != -1
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              end: direction != -1
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              colors: [
                Colors.black38,
                Colors.grey[100]!,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              direction == -1 ? Icons.chevron_left : Icons.chevron_right,
              color: Colors.white,
              size: 26,
            ),
          ),
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
    final isDesktop = ResponsiveHelper.isDesktop(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: isDesktop ? 150 : 90,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                category.strCategoryThumb,
                height: isDesktop ? 70 : 50,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: isDesktop ? 70 : 50,
                    child: const LoadingView(),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                category.strCategory,
                style: TextStyle(fontSize: isDesktop ? 14 : 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
