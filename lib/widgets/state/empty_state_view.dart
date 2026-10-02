import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

/// Centered illustration-style state: tonal icon badge, title, message and an optional action.
///
/// Used for empty lists, "no results" and (through [ErrorView]) error states so they
/// all share one look.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.sectionSpacing),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isError
                      ? colorScheme.errorContainer
                      : colorScheme.primaryContainer.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isError
                      ? colorScheme.onErrorContainer
                      : colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: UIConstants.defaultSpacing),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              if (message != null) ...[
                const SizedBox(height: UIConstants.defaultPadding),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: UIConstants.sectionSpacing),
                FilledButton.tonal(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
