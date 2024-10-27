import 'package:flutter/material.dart';
import '../../../utils/error_handler.dart';

class ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final String errString;

  const ErrorView({
    super.key,
    required this.onRetry,
    required this.errString,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ErrorHandler.buildErrorWidget(errString),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
