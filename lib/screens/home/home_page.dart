import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_explorer/screens/home/widgets/favorites_button.dart';
import 'package:recipe_explorer/widgets/connectivity/connected_wrapper.dart';
import '../../constants/text_constants.dart';
import '../../constants/ui_constants.dart';
import '../../widgets/error/error_view.dart';
import '../../routes/app_routes.dart';
import 'widgets/offline_app_bar.dart';
import 'widgets/categories.dart';
import 'widgets/custom_search_bar.dart';
import 'widgets/default_recipes.dart';

class HomePageController extends GetxController {
  void onCategorySelected(String category) {
    Get.toNamed(
      AppRoutes.results,
      arguments: {
        AppRoutes.categoryNameParam: category,
      },
    );
  }

  void searchMeals(String query, {bool byName = true, bool byIngredient = false}) {
    if (query.trim().isNotEmpty) {
      Get.toNamed(
        AppRoutes.results,
        arguments: {
          AppRoutes.searchQueryParam: query,
          AppRoutes.searchByNameParam: byName,
          AppRoutes.searchByIngredientParam: byIngredient,
        },
      );
    }
  }
}

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller only if not already created
    Get.lazyPut(() => HomePageController());

    return Scaffold(
      body: SafeArea(
        child: ConnectivityWrapper(
          errorBuilder: (retryCallback) => Column(
            children: [
              const OfflineAppBar(),
              Expanded(
                child: Center(
                  child: ErrorView(
                    errString: TextConstants.loadError,
                    onRetry: retryCallback,
                  ),
                ),
              ),
            ],
          ),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(UIConstants.defaultPadding),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          CustomSearchBar(
                            onSearch: (query, {bool byName = true, bool byIngredient = false}) =>
                                controller.searchMeals(query,
                                    byName: byName, byIngredient: byIngredient),
                          ),
                          const SizedBox(width: 8),
                          const FavoritesButton(),
                        ],
                      ),
                    ),
                    CategoriesSection(
                      onCategorySelected: controller.onCategorySelected,
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ],
            body: const DefaultRecipesSection(),
          ),
        ),
      ),
    );
  }
}
