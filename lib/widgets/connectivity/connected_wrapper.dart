import 'package:flutter/material.dart';
import 'package:recipe_explorer/widgets/loading/loading_view.dart';
import '../../services/connectivity_service.dart';
import '../error/error_view.dart';

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
  final ConnectivityService _connectivity = ConnectivityService.instance;
  bool _isConnected = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _setupConnectivityListener();
  }

  Future<void> _initConnectivity() async {
    final isConnected = await _connectivity.checkConnectivity();
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
        _isInitialized = true;
      });
    }
  }

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

    if (!_isConnected) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_initConnectivity);
      }
      return ErrorView(
        errString: 'No internet connection',
        onRetry: _initConnectivity,
      );
    }

    return widget.child;
  }
}
