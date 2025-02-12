import 'package:flutter/material.dart';

/// A reusable widget for displaying error messages using SelectableText.rich
/// with proper styling and selection capability.
class ErrorText extends StatelessWidget {
  const ErrorText({
    super.key,
    required this.message,
    this.textAlign = TextAlign.start,
  });

  final String message;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SelectableText.rich(
        TextSpan(
          text: message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
        textAlign: textAlign,
      ),
    );
  }
}
