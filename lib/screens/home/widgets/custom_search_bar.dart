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
import 'package:get/get.dart';
import '../../../constants/text_constants.dart';
import '../../../constants/ui_constants.dart';

class CustomSearchBarController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final byName = true.obs;
  final byIngredient = false.obs;

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void handleSearch(Function(String, {bool byName, bool byIngredient}) onSearch) {
    final query = textController.text.trim();
    if (query.isNotEmpty) {
      onSearch(
        query,
        byName: byName.value,
        byIngredient: byIngredient.value,
      );
      textController.clear();
    }
  }

  void showFilterDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
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
                onPressed: Get.back,
              ),
            ),
          ],
        ),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text(TextConstants.searchByName),
              value: byName.value,
              onChanged: (value) => byName.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text(TextConstants.searchByIngredient),
              value: byIngredient.value,
              onChanged: (value) => byIngredient.value = value ?? false,
            ),
          ],
        )),
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
                  controller: controller.textController,
                  decoration: const InputDecoration(
                    hintText: TextConstants.searchHint,
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => controller.handleSearch(onSearch),
                ),
              ),

              // Filter Icon Button
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () => controller.showFilterDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
