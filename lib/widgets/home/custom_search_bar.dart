import 'package:flutter/material.dart';

enum SearchType {
  name,
  ingredient,
  both,
}

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String query, SearchType type) onSearch;

  const CustomSearchBar({
    required this.controller,
    required this.onSearch,
  });

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  SearchType _selectedType = SearchType.both;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: 'Search recipes',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => widget.onSearch(
                  widget.controller.text,
                  _selectedType,
                ),
              ),
            ),
            onSubmitted: (value) => widget.onSearch(value, _selectedType),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRadioOption(SearchType.name, 'By Name'),
              _buildRadioOption(SearchType.ingredient, 'By Ingredient'),
              _buildRadioOption(SearchType.both, 'Both'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(SearchType type, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<SearchType>(
          value: type,
          groupValue: _selectedType,
          onChanged: (SearchType? value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
              });
            }
          },
        ),
        Text(label),
      ],
    );
  }
}
