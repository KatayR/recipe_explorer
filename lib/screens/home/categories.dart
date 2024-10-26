import 'dart:ui';

import 'package:flutter/material.dart';
import '/models/category_model.dart';
import '/utils/responsive_helper.dart';

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
          width: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: direction == -1
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              end: direction == -1
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              colors: [
                Colors.black54,
                Colors.black12,
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
          width: isDesktop ? 150 : 100,
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
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
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
