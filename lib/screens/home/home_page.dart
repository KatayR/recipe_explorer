import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_explorer/widgets/connectivity/connected_wrapper.dart';
import '../../constants/text_constants.dart';
import '../../constants/ui_constants.dart';
import '../../widgets/error/error_view.dart';
import '../../widgets/section_header.dart';
import '../../routes/app_routes.dart';
import 'widgets/home_header.dart';
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

    const horizontalPadding =
        EdgeInsets.symmetric(horizontal: UIConstants.pagePadding);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ConnectivityWrapper(
          errorBuilder: (retryCallback) => Column(
            children: [
              const OfflineAppBar(),
              Expanded(
                child: ErrorView(
                  errString: TextConstants.noInternetError,
                  message: TextConstants.offlineMessage,
                  icon: Icons.wifi_off_rounded,
                  onRetry: retryCallback,
                ),
              ),
            ],
          ),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(
                        UIConstants.pagePadding,
                        UIConstants.doublePadding,
                        UIConstants.pagePadding,
                        UIConstants.doublePadding,
                      ),
                      child: HomeHeader(),
                    ),
                    Padding(
                      padding: horizontalPadding,
                      child: CustomSearchBar(
                        onSearch: (query, {bool byName = true, bool byIngredient = false}) =>
                            controller.searchMeals(query,
                                byName: byName, byIngredient: byIngredient),
                      ),
                    ),
                    const SizedBox(height: UIConstants.sectionSpacing),
                    const Padding(
                      padding: horizontalPadding,
                      child: SectionHeader(title: TextConstants.categoriesTitle),
                    ),
                    const SizedBox(height: 12),
                    CategoriesSection(
                      onCategorySelected: controller.onCategorySelected,
                    ),
                    const SizedBox(height: UIConstants.defaultSpacing),
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
