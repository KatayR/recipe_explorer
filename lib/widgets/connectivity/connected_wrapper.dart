import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import 'package:recipe_explorer/widgets/loading/loading_view.dart';
import '../../services/connectivity_service.dart';
import '../error/error_view.dart';

/// Controller for the ConnectivityWrapper widget that manages connectivity state.
class ConnectivityWrapperController extends GetxController {
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  
  final isConnected = false.obs;
  final isInitialized = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _setupConnectivityListener();
  }
  
  /// Initializes the connectivity check and updates the state accordingly.
  Future<void> initConnectivity() async {
    final connected = await _connectivity.checkConnectivity();
    isConnected.value = connected;
    isInitialized.value = true;
  }
  
  Future<void> _initConnectivity() async {
    await initConnectivity();
  }
  
  /// Sets up a listener for connectivity changes and updates the state when
  /// the connectivity status changes.
  void _setupConnectivityListener() {
    _connectivity.onConnectedChanged.listen((connected) {
      isConnected.value = connected;
    });
  }
}

/// A widget that wraps its child with connectivity checking functionality.
///
/// The `ConnectivityWrapper` listens to connectivity changes and displays
/// different widgets based on the current connectivity status. It shows a
/// loading view while the initial connectivity check is being performed,
/// an error view when there is no internet connection, and the provided
/// child widget when the device is connected to the internet.
///
/// The `errorBuilder` parameter can be used to provide a custom error widget
/// that will be displayed when there is no internet connection.
///
/// Example usage:
///
/// ```dart
/// ConnectivityWrapper(
///   child: MyConnectedWidget(),
///   errorBuilder: (retryCallback) => MyCustomErrorWidget(onRetry: retryCallback),
/// )
/// ```
///
/// The `ConnectivityWrapper` relies on a `ConnectivityService` to check and
/// listen for connectivity changes.
class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  final Widget Function(VoidCallback retryCallback)? errorBuilder;
  final String? controllerTag;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.errorBuilder,
    this.controllerTag,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller with unique tag to avoid conflicts
    final uniqueTag = controllerTag ?? UniqueKey().toString();
    Get.put(ConnectivityWrapperController(), tag: uniqueTag);
    final controller = Get.find<ConnectivityWrapperController>(tag: uniqueTag);
    
    return Obx(() {
      // Show loading until initial check is complete
      if (!controller.isInitialized.value) {
        return const LoadingView();
      }

      // Show error view if not connected to the internet
      if (!controller.isConnected.value) {
        if (errorBuilder != null) {
          return errorBuilder!(controller.initConnectivity);
        }
        return ErrorView(
          errString: TextConstants.noInternetError,
          onRetry: controller.initConnectivity,
        );
      }

      // Show the child widget if connected to the internet
      return child;
    });
  }
}
