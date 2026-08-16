/// Full-screen placeholders for the states every async screen has.
///
/// Widgets rather than `_buildX()` methods, so they can be `const`, rebuild
/// independently, and show up by name in the widget inspector.
library;

import 'package:material_ui/material_ui.dart';

/// Centred spinner with an optional caption.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final String? text = message;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CircularProgressIndicator(),
          if (text != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Inline "loading the next page" strip, for the foot of a paginated list.
class AppLoadingMoreIndicator extends StatelessWidget {
  const AppLoadingMoreIndicator({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Flexible(child: Text(message)),
        ],
      ),
    );
  }
}

/// Error placeholder.
///
/// Two constructors rather than nullable `onRetry` + nullable `retryLabel`: a
/// retry button with no label, or a label with no callback, are states that
/// simply cannot be expressed this way.
class AppErrorView extends StatelessWidget {
  /// A failure the user cannot act on.
  const AppErrorView({required this.message, super.key})
    : onRetry = null,
      retryLabel = null;

  /// A failure worth offering a retry for.
  const AppErrorView.withRetry({
    required this.message,
    required VoidCallback this.onRetry,
    required String this.retryLabel,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? retry = onRetry;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (retry != null) ...<Widget>[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: retry, child: Text(retryLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Nothing here" placeholder.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    required this.message,
    this.icon = Icons.search_off,
    super.key,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 56,
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
