import 'package:flutter/material.dart';
import '../../models/category_model.dart';

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final Function(String category) onCategorySelected;

  CategoryList({required this.categories, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => onCategorySelected(category.strCategory),
            child: Container(
              width: 100,
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Image.network(category.strCategoryThumb, height: 50),
                  SizedBox(height: 4),
                  Text(category.strCategory, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
