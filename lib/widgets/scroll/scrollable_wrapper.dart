import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScrollableWrapperController extends GetxController {
  late ScrollController scrollController;
  final showButton = false.obs;
  final double showButtonAtOffset;
  bool _isDisposed = false;
  
  ScrollableWrapperController({required this.showButtonAtOffset});
  
  void initScrollController(ScrollController? providedController) {
    scrollController = providedController ?? ScrollController();
    if (!_isDisposed) {
      scrollController.addListener(_scrollListener);
    }
  }
  
  @override
  void onClose() {
    _isDisposed = true;
    // Always try to remove listener if controller exists
    try {
      scrollController.removeListener(_scrollListener);
    } catch (_) {
      // Ignore errors if listener wasn't added
    }
    super.onClose();
  }
  
  void _scrollListener() {
    if (_isDisposed) return;
    
    final shouldShowButton = scrollController.offset >= showButtonAtOffset;
    if (shouldShowButton != showButton.value) {
      showButton.value = shouldShowButton;
    }
  }
  
  Future<void> scrollToTop(BuildContext context) async {
    final ancestor = context.findAncestorStateOfType<NestedScrollViewState>();

    if (ancestor != null) {
      // For NestedScrollView, I need to handle both controllers carefully
      if (scrollController.hasClients) {
        // First scroll the inner list to top
        await scrollController.animateTo(
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
      if (scrollController.hasClients) {
        await scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }
}

class ScrollableWrapper extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final double showButtonAtOffset;
  final FloatingActionButton? existingFab;
  final bool useScaffold;
  final String? title;
  final List<Widget>? actions;
  final String? controllerTag;

  const ScrollableWrapper({
    super.key,
    required this.child,
    this.controller,
    this.showButtonAtOffset = 300,
    this.existingFab,
    this.useScaffold = true,
    this.title,
    this.actions,
    this.controllerTag,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller with unique tag to avoid conflicts
    final uniqueTag = controllerTag ?? UniqueKey().toString();
    Get.put(ScrollableWrapperController(showButtonAtOffset: showButtonAtOffset), tag: uniqueTag);
    final getxController = Get.find<ScrollableWrapperController>(tag: uniqueTag);
    
    // Initialize scroll controller after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getxController.initScrollController(controller);
    });
    
    Widget buildScrollToTopButton() {
      return Obx(() {
        if (!getxController.showButton.value) return const SizedBox.shrink();

        return Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            mini: true,
            onPressed: () => getxController.scrollToTop(context),
            child: const Icon(Icons.arrow_upward),
          ),
        );
      });
    }
    
    // Instead of refactoring the whole homepage to avoid "doube-scaffold" this seems like a better approach
    final content = Stack(
      children: [
        child,
        buildScrollToTopButton(),
      ],
    );

    if (!useScaffold) {
      return content;
    }

    //
    // What's below is a future-proofing attempt to handle the case where there may be an existing FAB in the page.
    //

    return Obx(() {
      Widget? fab; // Declare a variable to hold our FAB configuration

      if (getxController.showButton.value) {
        // If we should show the scroll-to-top button
        if (existingFab != null) {
          // If there's already another FAB in the page
          // Create a Column with both buttons stacked vertically
          fab = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Put scroll-to-top button on top
              FloatingActionButton(
                mini: true,
                onPressed: () => getxController.scrollToTop(context),
                child: const Icon(Icons.arrow_upward),
              ),
              // Add some space between buttons
              const SizedBox(height: 16),
              // Put the existing FAB below
              existingFab!,
            ],
          );
        } else {
          // If there's no existing FAB
          // Just show the scroll-to-top button
          fab = FloatingActionButton(
            mini: true,
            onPressed: () => getxController.scrollToTop(context),
            child: const Icon(Icons.arrow_upward),
          );
        }
      } else {
        // If we shouldn't show the scroll-to-top button
        // Just show the existing FAB if there is one
        fab = existingFab;
      }
      // End of future-proofing attempt

      return Scaffold(
        appBar: title != null
            ? AppBar(
                title: Text(title!),
                actions: actions,
              )
            : null,
        body: child,
        floatingActionButton: fab,
      );
    });
  }
}