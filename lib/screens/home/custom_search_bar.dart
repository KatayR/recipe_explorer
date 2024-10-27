import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Search recipes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onSubmitted: (_) => _handleSearch(),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<void>(
                icon: const Icon(Icons.tune),
                itemBuilder: (context) => [
                  CheckedPopupMenuItem(
                    value: null,
                    checked: _byName,
                    onTap: () => setState(() => _byName = !_byName),
                    child: const Text('Search by Name'),
                  ),
                  CheckedPopupMenuItem(
                    value: null,
                    checked: _byIngredient,
                    onTap: () => setState(() => _byIngredient = !_byIngredient),
                    child: const Text('Search by Ingredient'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
