import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../widgets/loading/loading_view.dart';
import '../../../widgets/error/error_view.dart';
import '../../../services/api_service.dart';
import '../../../models/category_model.dart';
import '../../../utils/responsive_helper.dart';

class CategoriesSection extends StatefulWidget {
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
  final ApiService _apiService;
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;

  _CategoriesSectionState() : _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

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

class CategoryList extends StatefulWidget {
  final List<Category> categories;
  final Function(String category) onCategorySelected;

  const CategoryList({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
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

  void _updateArrows() {
    setState(() {
      _showLeftArrow = _scrollController.position.pixels > 0;
      _showRightArrow = _scrollController.position.pixels <
          _scrollController.position.maxScrollExtent;
    });
  }

  void _scroll(double direction) {
    _scrollController.animateTo(
      _scrollController.offset + (direction * 200),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
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

class _ScrollArrow extends StatelessWidget {
  final int direction;
  final VoidCallback onTap;

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
          width: 16,
          decoration: BoxDecoration(
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
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final Category category;
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
