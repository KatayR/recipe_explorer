/// A custom search bar widget that allows users to search for recipes by name or ingredient.
///
/// The [CustomSearchBar] widget provides a text field for entering search queries and a button
/// to open a filter dialog for selecting search criteria.
///
/// The [onSearch] callback is triggered when a search is performed, passing the search query
/// and the selected search criteria.
///
/// The widget uses GetX reactive variables to manage search criteria (by name or by ingredient) and
/// text field input through a dedicated controller.
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
/// The filter sheet allows users to select whether to search by name, by ingredient, or both.
/// The search criteria are stored in the reactive [byName] and [byIngredient] variables.
///
/// The [handleSearch] method is called when a search is performed, and it triggers the [onSearch]
/// callback with the current search query and criteria.
///
/// The [showFilterSheet] method displays a bottom sheet with filter chips for selecting the search criteria.
///
/// The text field input is managed by a [TextEditingController], which is disposed of in the [onClose] method.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/text_constants.dart';
import '../../../constants/ui_constants.dart';
import '../../../utils/input_validator.dart';

class CustomSearchBarController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final byName = true.obs;
  final byIngredient = false.obs;

  /// True when filters differ from the default (name only), so the filter button shows a dot.
  bool get hasCustomFilters => !byName.value || byIngredient.value;

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  /// Shows validation feedback with Flutter's ScaffoldMessenger
  /// (Get.snackbar fails with "No Overlay widget found" on current Flutter versions).
  void _showValidationError(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(message),
          ],
        ),
      ));
  }

  void handleSearch(
    BuildContext context,
    Function(String, {bool byName, bool byIngredient}) onSearch,
  ) {
    final query = textController.text;
    
    // Validate search query
    final queryValidation = InputValidator.validateSearchQuery(query);
    if (!queryValidation.isValid) {
      _showValidationError(
        context,
        TextConstants.invalidSearchTitle,
        queryValidation.errorMessage!,
      );
      return;
    }
    
    // Validate search filters
    final filterValidation = InputValidator.validateSearchFilters(byName.value, byIngredient.value);
    if (!filterValidation.isValid) {
      _showValidationError(
        context,
        TextConstants.noFilterSelectedTitle,
        filterValidation.errorMessage!,
      );
      return;
    }
    
    // Sanitize and execute search
    final sanitizedQuery = InputValidator.sanitizeSearchQuery(query);
    onSearch(
      sanitizedQuery,
      byName: byName.value,
      byIngredient: byIngredient.value,
    );
    textController.clear();
  }

  void showFilterSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            UIConstants.sectionSpacing,
            0,
            UIConstants.sectionSpacing,
            UIConstants.sectionSpacing,
          ),
          child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(TextConstants.filtersTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                TextConstants.filtersSubtitle,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: UIConstants.defaultSpacing),
              Wrap(
                spacing: UIConstants.defaultPadding,
                children: [
                  FilterChip(
                    label: const Text(TextConstants.searchByName),
                    selected: byName.value,
                    onSelected: (value) => byName.value = value,
                  ),
                  FilterChip(
                    label: const Text(TextConstants.searchByIngredient),
                    selected: byIngredient.value,
                    onSelected: (value) => byIngredient.value = value,
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.sectionSpacing),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(TextConstants.doneButton),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}

class CustomSearchBar extends GetView<CustomSearchBarController> {
  final Function(String, {bool byName, bool byIngredient}) onSearch;
  final String? controllerTag;

  const CustomSearchBar({
    super.key,
    required this.onSearch,
    this.controllerTag,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller with unique tag to avoid conflicts
    final uniqueTag = controllerTag ?? UniqueKey().toString();
    Get.put(CustomSearchBarController(), tag: uniqueTag);
    final controller = Get.find<CustomSearchBarController>(tag: uniqueTag);
    
    return TextField(
      controller: controller.textController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: TextConstants.searchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        // Filter button; shows a dot when non-default filters are active
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            tooltip: TextConstants.filtersTooltip,
            icon: Obx(() => Badge(
              smallSize: 8,
              isLabelVisible: controller.hasCustomFilters,
              child: const Icon(Icons.tune_rounded),
            )),
            onPressed: () => controller.showFilterSheet(context),
          ),
        ),
      ),
      onSubmitted: (_) => controller.handleSearch(context, onSearch),
    );
  }
}
