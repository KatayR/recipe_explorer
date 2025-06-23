import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_explorer/constants/text_constants.dart';
import 'package:recipe_explorer/widgets/loading/loading_view.dart';
import '../../services/connectivity_service.dart';
import '../error/error_view.dart';

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
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final Widget Function(VoidCallback retryCallback)? errorBuilder;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  bool _isConnected = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _setupConnectivityListener();
  }

  /// Initializes the connectivity check and updates the state accordingly.
  Future<void> _initConnectivity() async {
    final isConnected = await _connectivity.checkConnectivity();
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
        _isInitialized = true;
      });
    }
  }

  /// Sets up a listener for connectivity changes and updates the state when
  /// the connectivity status changes.
  void _setupConnectivityListener() {
    _connectivity.onConnectedChanged.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading until initial check is complete
    if (!_isInitialized) {
      return const LoadingView();
    }

    // Show error view if not connected to the internet
    if (!_isConnected) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_initConnectivity);
      }
      return ErrorView(
        errString: TextConstants.noInternetError,
        onRetry: _initConnectivity,
      );
    }

    // Show the child widget if connected to the internet
    return widget.child;
  }
}
