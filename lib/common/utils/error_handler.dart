import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'logger.dart';

/// Represents a user-friendly error with a title and message
class AppError {
  final String title;
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;
  final ErrorCategory category;
  final ErrorSeverity severity;
  final String? code;
  final Map<String, dynamic>? context;

  const AppError({
    required this.title,
    required this.message,
    this.originalError,
    this.stackTrace,
    this.category = ErrorCategory.unknown,
    this.severity = ErrorSeverity.error,
    this.code,
    this.context,
  });

  @override
  String toString() => '$title: $message';

  bool get isCritical => severity == ErrorSeverity.critical;
  bool get isRetryable => _isRetryableError();

  bool _isRetryableError() {
    if (originalError is FirebaseException) {
      final code = (originalError as FirebaseException).code;
      return ['network-request-failed', 'unavailable'].contains(code);
    }
    return false;
  }
}

/// Categories of errors for better organization and handling
enum ErrorCategory {
  auth('Authentication'),
  video('Video Processing'),
  storage('Storage'),
  network('Network'),
  processing('Processing'),
  validation('Validation'),
  database('Database'),
  permission('Permission'),
  unknown('Unknown');

  final String label;
  const ErrorCategory(this.label);
}

/// Severity levels for errors
enum ErrorSeverity {
  critical('Critical'),
  error('Error'),
  warning('Warning'),
  info('Info');

  final String label;
  const ErrorSeverity(this.label);
}

class ErrorHandler {
  static AppError handleError(Object error, [StackTrace? stackTrace]) {
    Logger.error('Error caught', {
      'error': error,
      'stackTrace': stackTrace,
    });

    // Firebase Auth Errors
    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    }

    // Firebase Functions Errors
    if (error is FirebaseFunctionsException) {
      return _handleFunctionsError(error);
    }

    // Firebase Storage Errors
    if (error is FirebaseException && error.plugin == 'firebase_storage') {
      return _handleStorageError(error);
    }

    // Network errors
    if (error is NetworkException) {
      return _handleNetworkError(error);
    }

    // Processing errors
    if (error is ProcessingException) {
      return _handleProcessingError(error);
    }

    // Generic error fallback
    return AppError(
      title: 'Error',
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
      category: ErrorCategory.unknown,
      severity: ErrorSeverity.error,
    );
  }

  static AppError _handleAuthError(FirebaseAuthException error) {
    final message = switch (error.code) {
      'user-not-found' => 'No user found with this email.',
      'wrong-password' => 'Incorrect password.',
      'email-already-in-use' => 'This email is already registered.',
      'weak-password' => 'Password is too weak.',
      'invalid-email' => 'Invalid email address.',
      'user-disabled' => 'This account has been disabled.',
      'operation-not-allowed' => 'Operation not allowed.',
      'requires-recent-login' => 'Please log in again to continue.',
      _ => error.message ?? 'Authentication error occurred.',
    };

    return AppError(
      title: 'Authentication Error',
      message: message,
      originalError: error,
      category: ErrorCategory.auth,
      severity: ErrorSeverity.error,
      code: error.code,
    );
  }

  static AppError _handleFunctionsError(FirebaseFunctionsException error) {
    final message = switch (error.code) {
      'not-found' => 'The requested resource was not found.',
      'already-exists' => 'The resource already exists.',
      'permission-denied' =>
        'You don\'t have permission to perform this action.',
      'unauthenticated' => 'Please log in to continue.',
      'unavailable' => 'Service is currently unavailable.',
      'internal' => 'An internal error occurred.',
      _ => error.message ?? 'An error occurred while processing your request.',
    };

    final severity = switch (error.code) {
      'internal' => ErrorSeverity.critical,
      'unavailable' => ErrorSeverity.warning,
      _ => ErrorSeverity.error,
    };

    return AppError(
      title: 'Service Error',
      message: message,
      originalError: error,
      category: ErrorCategory.processing,
      severity: severity,
      code: error.code,
      context: error.details as Map<String, dynamic>?,
    );
  }

  static AppError _handleStorageError(FirebaseException error) {
    final message = switch (error.code) {
      'storage/object-not-found' => 'File not found.',
      'storage/unauthorized' => 'Not authorized to access this file.',
      'storage/canceled' => 'Operation was cancelled.',
      'storage/unknown' => 'Unknown error occurred.',
      _ => error.message ?? 'Storage error occurred.',
    };

    return AppError(
      title: 'Storage Error',
      message: message,
      originalError: error,
      category: ErrorCategory.storage,
      severity: ErrorSeverity.error,
      code: error.code,
    );
  }

  static AppError _handleNetworkError(NetworkException error) {
    return AppError(
      title: 'Network Error',
      message: 'Please check your internet connection and try again.',
      originalError: error,
      category: ErrorCategory.network,
      severity: ErrorSeverity.warning,
    );
  }

  static AppError _handleProcessingError(ProcessingException error) {
    return AppError(
      title: 'Processing Error',
      message: error.message,
      originalError: error,
      category: ErrorCategory.processing,
      severity: error.isCritical ? ErrorSeverity.critical : ErrorSeverity.error,
    );
  }

  /// Shows an error dialog to the user with appropriate styling based on severity
  static Future<void> showErrorDialog(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          error.title,
          style: TextStyle(
            color: _getErrorColor(error.severity),
            fontWeight: error.severity == ErrorSeverity.critical
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(error.message),
            if (error.severity == ErrorSeverity.critical)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'This is a critical error that requires immediate attention.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (error.isRetryable && onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  /// Shows an error in a SnackBar with appropriate styling based on severity
  static void showErrorSnackBar(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: _getErrorColor(error.severity),
        action: error.isRetryable && onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                onPressed: onRetry,
                textColor: Theme.of(context).colorScheme.onError,
              )
            : null,
        duration: error.severity == ErrorSeverity.critical
            ? const Duration(seconds: 10)
            : const Duration(seconds: 4),
      ),
    );
  }

  /// Shows error text inline with appropriate styling based on severity
  static Widget buildErrorText(AppError error) {
    return SelectableText.rich(
      TextSpan(
        children: [
          WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                _getErrorIcon(error.severity),
                color: _getErrorColor(error.severity),
                size: 16,
              ),
            ),
          ),
          TextSpan(text: error.message),
        ],
      ),
      style: TextStyle(color: _getErrorColor(error.severity)),
    );
  }

  static Color _getErrorColor(ErrorSeverity severity) {
    return switch (severity) {
      ErrorSeverity.critical => Colors.red[900]!,
      ErrorSeverity.error => Colors.red,
      ErrorSeverity.warning => Colors.orange,
      ErrorSeverity.info => Colors.blue,
    };
  }

  static IconData _getErrorIcon(ErrorSeverity severity) {
    return switch (severity) {
      ErrorSeverity.critical => Icons.error,
      ErrorSeverity.error => Icons.error_outline,
      ErrorSeverity.warning => Icons.warning,
      ErrorSeverity.info => Icons.info_outline,
    };
  }
}

/// Custom exceptions
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class ProcessingException implements Exception {
  final String message;
  final bool isCritical;
  ProcessingException(this.message, {this.isCritical = false});
}
