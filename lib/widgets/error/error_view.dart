/// A widget that displays an error message with an optional retry button.
///
/// The [ErrorView] widget is used to show an error message to the user,
/// along with an optional retry button that can trigger a callback function
/// when pressed.
///
/// The [errString] parameter is required and specifies the error message
/// to be displayed. The [onRetry] parameter is optional and specifies a
/// callback function to be executed when the retry button is pressed.
///
/// Example usage:
/// ```dart
/// ErrorView(
///   errString: 'An error occurred. Please try again.',
///   onRetry: () {
///     // Retry logic here
///   },
/// )
/// ```
import 'package:flutter/material.dart';
import 'package:recipe_explorer/constants/text_constants.dart';

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
              child: const Text(TextConstants.tryAgainButton),
            ),
        ],
      ),
    );
  }
}
