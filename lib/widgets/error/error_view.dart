/// A widget that displays an error message with an optional retry button.
///
/// The [ErrorView] widget is used to show an error message to the user,
/// along with an optional retry button that can trigger a callback function
/// when pressed.
///
/// The [errString] parameter is required and specifies the error message
/// to be displayed. The [onRetry] parameter is optional and specifies a
/// callback function to be executed when the retry button is pressed.
/// The optional [message] adds a secondary explanation line.
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
import '../state/empty_state_view.dart';

class ErrorView extends StatelessWidget {
  final VoidCallback? onRetry;
  final String errString;
  final String? message;
  final IconData icon;

  const ErrorView({
    super.key,
    this.onRetry,
    required this.errString,
    this.message,
    this.icon = Icons.cloud_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: icon,
      title: errString,
      message: message,
      actionLabel: TextConstants.tryAgainButton,
      onAction: onRetry,
      isError: true,
    );
  }
}
