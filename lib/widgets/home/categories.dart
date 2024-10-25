import 'package:flutter/material.dart';
import '/models/category_model.dart';
import '/utils/responsive_helper.dart';

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final Function(String category) onCategorySelected;

  const CategoryList(
      {super.key, required this.categories, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveHelper.isMobile(context) ? 100 : 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryItem(
            category: category,
            onTap: () => onCategorySelected(category.strCategory),
          );
        },
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryItem({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isDesktop ? 150 : 100,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Image.network(category.strCategoryThumb,
                height: isDesktop ? 70 : 50),
            const SizedBox(height: 4),
            Text(
              category.strCategory,
              style: TextStyle(fontSize: isDesktop ? 14 : 12),
            ),
          ],
        ),
      ),
    );
  }
}
