/// A custom search bar widget that allows users to search for recipes by name or ingredient.
///
/// The [CustomSearchBar] widget provides a text field for entering search queries and a button
/// to open a filter dialog for selecting search criteria.
///
/// The [onSearch] callback is triggered when a search is performed, passing the search query
/// and the selected search criteria.
///
/// The widget maintains the state of the search criteria (by name or by ingredient) and the
/// text field input.
///
/// Example usage:
///
/// ```dart
/// CustomSearchBar(
///   onSearch: (query, {byName, byIngredient}) {
///     // Handle search logic here
///   },
/// )
/// ```
///
/// The filter dialog allows users to select whether to search by name, by ingredient, or both.
/// The search criteria are stored in the [_byName] and [_byIngredient] state variables.
///
/// The [_handleSearch] method is called when a search is performed, and it triggers the [onSearch]
/// callback with the current search query and criteria.
///
/// The [_showFilterDialog] method displays a dialog with checkboxes for selecting the search criteria.
///
/// The text field input is managed by a [TextEditingController], which is disposed of in the [dispose] method.

import 'package:flutter/material.dart';
import '../../../constants/text_constants.dart';
import '../../../constants/ui_constants.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String, {bool byName, bool byIngredient}) onSearch;

  const CustomSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final _controller = TextEditingController();
  bool _byName = true;
  bool _byIngredient = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch(
        query,
        byName: _byName,
        byIngredient: _byIngredient,
      );
      _controller.clear();
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text(TextConstants.filtersTitle),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text(TextConstants.searchByName),
                value: _byName,
                onChanged: (value) {
                  setState(() => _byName = value ?? false);
                },
              ),
              CheckboxListTile(
                title: const Text(TextConstants.searchByIngredient),
                value: _byIngredient,
                onChanged: (value) {
                  setState(() => _byIngredient = value ?? false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        elevation: 2,
        borderRadius: UIConstants.circularBorderRadious,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: UIConstants.circularBorderRadious,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: TextConstants.searchHint,
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleSearch(),
                ),
              ),

              // Filter Icon Button
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () => _showFilterDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
