/// A GetX widget that displays search results or meals by category.
///
/// The [ResultsPage] widget fetches and displays a list of meals based on the
/// provided search query or category name.
/// The widget requires either a [searchQuery] or a [categoryName] to be provided.
///
/// The [searchByName] and [searchByIngredient] flags determine the type of search
/// to be performed when a [searchQuery] is provided.
///
/// The [ResultsPage] consists of the following main components:
/// - An app bar displaying the search query or category name.
/// - A body that displays a loading indicator, error message, or the list of meals.
///
/// The meals are fetched using the [ApiService].
///
/// The widget also supports navigation to a detailed recipe page when a meal is
/// selected.
///
/// Example usage:
///
/// ```dart
/// ResultsPage(
///   searchQuery: 'Chicken',
///   searchByName: true,
///   searchByIngredient: false,
/// );
/// ```
///
/// or
///
/// ```dart
/// ResultsPage(
///   categoryName: 'Dessert',
/// );
/// ```
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import '../../../services/api_service.dart';
import '../../../services/scroll_preloader.dart';
import '../../models/meal_model.dart';
import '../../widgets/connectivity/connected_wrapper.dart';
import '../../widgets/error/error_view.dart';
import '../../widgets/loading/loading_view.dart';
import '../../widgets/meal/meal_grid.dart';
import '../../widgets/scroll/scrollable_wrapper.dart';
import '../../routes/app_routes.dart';

class ResultsPageController extends GetxController {
  final ApiController _apiController = Get.find<ApiController>();

  var meals = <dynamic>[].obs;
  var isLoading = true.obs;
  var error = Rx<String?>(null);

  String? get searchQuery => _searchQuery;
  String? get categoryName => _categoryName;
  bool get searchByName => _searchByName;
  bool get searchByIngredient => _searchByIngredient;

  String? _searchQuery;
  String? _categoryName;
  bool _searchByName = true;
  bool _searchByIngredient = false;

  void initialize({
    String? searchQuery,
    String? categoryName,
    bool searchByName = true,
    bool searchByIngredient = false,
  }) {
    _searchQuery = searchQuery;
    _categoryName = categoryName;
    _searchByName = searchByName;
    _searchByIngredient = searchByIngredient;
    loadResults();
  }

  Future<void> loadResults() async {
    isLoading.value = true;
    error.value = null;

    try {
      final response = searchQuery != null
          ? await _apiController.searchMeals(
              query: searchQuery!,
              searchByName: searchByName,
              searchByIngredient: searchByIngredient,
            )
          : await _apiController.getMealsByCategory(categoryName!);

      isLoading.value = false;
      if (response.error != null) {
        error.value = TextConstants.loadError;
      } else {
        meals.value = response.data ?? [];
      }
    } catch (e) {
      isLoading.value = false;
      error.value = TextConstants.loadError;
    }
  }

  String getPageTitle() {
    if (searchQuery != null) {
      return '${TextConstants.searchResultsTitle}: $searchQuery';
    } else if (categoryName != null) {
      return '${TextConstants.categoryResultsTitle}: $categoryName';
    }
    return TextConstants.genericResultsTitle;
  }
}

class ResultsPage extends GetView<ResultsPageController> {
  final String? searchQuery;
  final String? categoryName;
  final bool searchByName;
  final bool searchByIngredient;

  const ResultsPage({
    super.key,
    this.searchQuery,
    this.categoryName,
    this.searchByName = true,
    this.searchByIngredient = false,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    ScrollPreloader? scrollPreloader;

    // Create a unique tag for this instance
    final tag = '${searchQuery ?? categoryName ?? 'results'}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Initialize controller with search parameters only if not already created
    Get.lazyPut(() => ResultsPageController(), tag: tag);
    final controller = Get.find<ResultsPageController>(tag: tag);
    controller.initialize(
      searchQuery: searchQuery,
      categoryName: categoryName,
      searchByName: searchByName,
      searchByIngredient: searchByIngredient,
    );

    void initializePreloading() async {
      if (controller.meals.isEmpty) return;

      // Extract image URLs from meals data
      final imageUrls = controller.meals
          .map((meal) => meal['strMealThumb'] as String)
          .where((url) => url.isNotEmpty)
          .toList();

      // Initialize scroll preloader service
      scrollPreloader = ScrollPreloader(imageUrls: imageUrls);
      await scrollPreloader!.initialize(context);

      // Set up scroll listener to delegate to the service
      scrollController.addListener(() {
        scrollPreloader!.onScroll(scrollController);
      });
    }

    void navigateToRecipe(Meal meal) {
      Get.toNamed(
        AppRoutes.recipe,
        arguments: {
          AppRoutes.mealIdParam: meal.idMeal,
          AppRoutes.mealNameParam: meal.strMeal,
        },
      );
    }

    Widget buildContent() {
      return Obx(() {
        if (controller.isLoading.value) {
          return const LoadingView();
        }

        if (controller.error.value != null) {
          return ErrorView(
            onRetry: controller.loadResults,
            errString: controller.error.value!,
          );
        }

        if (controller.meals.isEmpty) {
          return const ErrorView(
            errString: TextConstants.noResultsError,
          );
        }

        // Initialize preloading when meals are available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          initializePreloading();
        });

        return MealGrid(
          meals: controller.meals,
          onMealSelected: navigateToRecipe,
          scrollController: scrollController,
        );
      });
    }

    return ConnectivityWrapper(
      errorBuilder: (retryCallback) => ScrollableWrapper(
        controller: scrollController,
        title: controller.getPageTitle(),
        child: ErrorView(
          errString: TextConstants.noInternetError,
          onRetry: retryCallback,
        ),
      ),
      child: ScrollableWrapper(
        controller: scrollController,
        title: controller.getPageTitle(),
        child: buildContent(),
      ),
    );
  }
}
