import 'package:flutter/material.dart';

class ScrollableWrapper extends StatefulWidget {
  final Widget child;
  final ScrollController? controller;
  final double showButtonAtOffset;
  final FloatingActionButton? existingFab;
  final bool useScaffold;
  final String? title;
  final List<Widget>? actions;

  const ScrollableWrapper({
    super.key,
    required this.child,
    this.controller,
    this.showButtonAtOffset = 300,
    this.existingFab,
    this.useScaffold = true,
    this.title,
    this.actions,
  });

  @override
  State<ScrollableWrapper> createState() => _ScrollableWrapperState();
}

class _ScrollableWrapperState extends State<ScrollableWrapper> {
  late ScrollController _scrollController;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // Removing listener before disposal to prevent callbacks after dispose
    _scrollController.removeListener(_scrollListener);
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _scrollListener() {
    if (!mounted) return;

    final showButton = _scrollController.offset >= widget.showButtonAtOffset;
    if (showButton != _showButton) {
      setState(() => _showButton = showButton);
    }
  }

  Future<void> _scrollToTop() async {
    final ancestor = context.findAncestorStateOfType<NestedScrollViewState>();

    if (ancestor != null) {
      // For NestedScrollView, I need to handle both controllers carefully
      if (_scrollController.hasClients) {
        // First scroll the inner list to top
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }

      // Then scroll the outer controller to show the header
      await ancestor.outerController.animateTo(
        0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    } else {
      // For regular ScrollView, just scroll to top
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Widget _buildScrollToTopButton() {
    if (!_showButton) return const SizedBox.shrink();

    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        mini: true,
        onPressed: _scrollToTop,
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Instead of refactoring the whole homepage to avoid "doube-scaffold" this seems like a better approach
    final content = Stack(
      children: [
        widget.child,
        _buildScrollToTopButton(),
      ],
    );

    if (!widget.useScaffold) {
      return content;
    }

    //
    // What's below is a future-proofing attempt to handle the case where there may be an existing FAB in the page.
    //

    Widget? fab; // Declare a variable to hold our FAB configuration

    if (_showButton) {
      // If we should show the scroll-to-top button
      if (widget.existingFab != null) {
        // If there's already another FAB in the page
        // Create a Column with both buttons stacked vertically
        fab = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Put scroll-to-top button on top
            FloatingActionButton(
              mini: true,
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward),
            ),
            // Add some space between buttons
            const SizedBox(height: 16),
            // Put the existing FAB below
            widget.existingFab!,
          ],
        );
      } else {
        // If there's no existing FAB
        // Just show the scroll-to-top button
        fab = FloatingActionButton(
          mini: true,
          onPressed: _scrollToTop,
          child: const Icon(Icons.arrow_upward),
        );
      }
    } else {
      // If we shouldn't show the scroll-to-top button
      // Just show the existing FAB if there is one
      fab = widget.existingFab;
    }
    // End of future-proofing attempt

    return Scaffold(
      appBar: widget.title != null
          ? AppBar(
              title: Text(widget.title!),
              actions: widget.actions,
            )
          : null,
      body: widget.child,
      floatingActionButton: fab,
    );
  }
}
