import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final VoidCallback? onRetry;
  final String errString;

  const ErrorView({
    super.key,
    this.onRetry,
    required this.errString,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            errString,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
        ],
      ),
    );
  }
}
