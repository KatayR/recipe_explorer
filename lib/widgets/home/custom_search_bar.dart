import 'package:flutter/material.dart';

class SearchOptions {
  final bool byName;
  final bool byIngredient;

  const SearchOptions({
    required this.byName,
    required this.byIngredient,
  });

  bool get hasSelection => byName || byIngredient;
}

class CustomSearchBar extends StatefulWidget {
  final Function(String query, SearchOptions searchOptions) onSearch;
  final VoidCallback onClose;
  final bool isVisible;

  const CustomSearchBar({
    super.key,
    required this.onSearch,
    required this.onClose,
    required this.isVisible,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final AnimationController _animationController; // AI magic here
  late final Animation<double> _animation;
  bool _byName = true;
  bool _byIngredient = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Only god and the ChatGPT knows how this animation works
    _controller = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CustomSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
        _focusNode.requestFocus();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSearch() {
    if (!_byName && !_byIngredient) {
      setState(() => _byName = true);
    }

    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch(
        query,
        SearchOptions(
          byName: _byName,
          byIngredient: _byIngredient,
        ),
      );
      _controller.clear();
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      axisAlignment: -1,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
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
                PopupMenuButton<SearchOptions>(
                  icon: const Icon(Icons.tune),
                  onSelected: (SearchOptions options) {
                    setState(() {
                      _byName = options.byName;
                      _byIngredient = options.byIngredient;
                    });
                  },
                  itemBuilder: (BuildContext context) => [
                    CheckedPopupMenuItem(
                      value: SearchOptions(
                        byName: !_byName,
                        byIngredient: _byIngredient,
                      ),
                      checked: _byName,
                      child: const Text('Search by Name'),
                    ),
                    CheckedPopupMenuItem(
                      value: SearchOptions(
                        byName: _byName,
                        byIngredient: !_byIngredient,
                      ),
                      checked: _byIngredient,
                      child: const Text('Search by Ingredient'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
