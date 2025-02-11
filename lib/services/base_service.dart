import '../utils/error_handler.dart';
import '../utils/logger.dart';
import '../utils/transaction_context.dart';
import '../utils/error_context.dart';
import '../utils/transaction_decorator.dart';

/// Base class for all services providing standardized error handling and logging
abstract class BaseService {
  /// Executes an operation with standardized error handling and logging
  Future<T> executeOperation<T>({
    required Future<T> Function() operation,
    required String operationName,
    Map<String, dynamic>? context,
    ErrorCategory errorCategory = ErrorCategory.unknown,
    ErrorSeverity errorSeverity = ErrorSeverity.error,
    List<Type>? middleware,
  }) async {
    return TransactionDecorator.wrap(
      operation: () async {
        try {
          return await operation();
        } catch (e, st) {
          final transaction = TransactionManager.currentTransaction!;
          final errorContext = ErrorContextBuilder.fromTransaction(transaction)
            ..withSeverity(errorSeverity)
            ..addBreadcrumb('Operation failed')
            ..withState({'error': e.toString()});

          if (e is AppError) {
            // Preserve the original error's context but add transaction information
            final updatedError = AppError(
              title: e.title,
              message: e.message,
              originalError: e.originalError,
              stackTrace: e.stackTrace ?? st,
              category: e.category,
              severity: e.severity,
              code: e.code,
              context: {
                ...?e.context,
                'transaction': transaction.toMap(),
              },
            );
            throw updatedError;
          }

          final appError = errorContext.buildError(
            title: 'Operation Failed',
            message: e.toString(),
            originalError: e,
            stackTrace: st,
          );

          Logger.error(
            'Operation failed: $operationName',
            appError.context,
          );
          throw appError;
        }
      },
      operationName: operationName,
      category: errorCategory,
      metadata: context,
      middleware: middleware,
    );
  }

  /// Executes a cleanup operation with error logging but without throwing
  Future<bool> executeCleanup({
    required Future<void> Function() cleanup,
    required String cleanupName,
    Map<String, dynamic>? context,
    List<Type>? middleware,
  }) async {
    return TransactionDecorator.wrap(
      operation: () async {
        try {
          await cleanup();
          return true;
        } catch (e, st) {
          final transaction = TransactionManager.currentTransaction!;
          final errorContext = ErrorContextBuilder.fromTransaction(transaction)
            ..withSeverity(ErrorSeverity.warning)
            ..addBreadcrumb('Cleanup failed')
            ..withState({
              'error': e.toString(),
              'stackTrace': st.toString(),
            });

          Logger.warning(
            'Cleanup failed: $cleanupName',
            errorContext.build().toMap(),
          );
          return false;
        }
      },
      operationName: cleanupName,
      category: ErrorCategory.unknown,
      metadata: context,
      middleware: middleware,
    );
  }

  /// Executes multiple cleanup operations in parallel
  Future<void> executeMultipleCleanups({
    required List<Future<void> Function()> cleanups,
    required String cleanupName,
    Map<String, dynamic>? context,
    List<Type>? middleware,
  }) async {
    await TransactionDecorator.wrap(
      operation: () async {
        final transaction = TransactionManager.currentTransaction!;
        final results = await Future.wait(
          cleanups.map(
            (cleanup) => executeCleanup(
              cleanup: cleanup,
              cleanupName: '${cleanupName}_item',
              context: context,
            ),
          ),
          eagerError: false,
        );

        final failedCount = results.where((success) => !success).length;
        if (failedCount > 0) {
          final errorContext = ErrorContextBuilder.fromTransaction(transaction)
            ..withSeverity(ErrorSeverity.warning)
            ..addBreadcrumb('Some cleanup operations failed')
            ..withState({
              'totalOperations': cleanups.length,
              'failedOperations': failedCount,
            });

          Logger.warning(
            'Some cleanup operations failed',
            errorContext.build().toMap(),
          );
        }
      },
      operationName: cleanupName,
      category: ErrorCategory.unknown,
      metadata: {
        ...?context,
        'totalOperations': cleanups.length,
      },
      middleware: middleware,
    );
  }

  /// Validates input parameters and throws a validation error if invalid
  void validateInput({
    required Map<String, dynamic> parameters,
    required Map<String, String Function(dynamic)> validators,
  }) {
    final errors = <String, String>{};

    for (final entry in validators.entries) {
      final paramName = entry.key;
      final validator = entry.value;
      final value = parameters[paramName];

      try {
        final error = validator(value);
        if (error.isNotEmpty) {
          errors[paramName] = error;
        }
      } catch (e) {
        errors[paramName] = 'Invalid value: $e';
      }
    }

    if (errors.isNotEmpty) {
      final currentTransaction = TransactionManager.currentTransaction;
      final errorContext = currentTransaction != null
          ? ErrorContextBuilder.fromTransaction(currentTransaction)
          : ErrorContextBuilder();

      // Build the error context first
      final context = errorContext
          .withCategory(ErrorCategory.validation)
          .withSeverity(ErrorSeverity.warning)
          .withValidationErrors(errors.values.toList())
          .withState({'parameters': parameters}).build();

      // Then throw a properly constructed AppError
      throw AppError(
        title: 'Validation Error',
        message: 'Invalid parameters provided: ${errors.values.join(", ")}',
        category: ErrorCategory.validation,
        severity: ErrorSeverity.warning,
        context: context.toMap(),
      );
    }
  }

  /// Helper method to ensure a value is not null or throw a validation error
  T requireValue<T>(T? value, String paramName) {
    if (value == null) {
      final currentTransaction = TransactionManager.currentTransaction;
      final errorContext = currentTransaction != null
          ? ErrorContextBuilder.fromTransaction(currentTransaction)
          : ErrorContextBuilder();

      // Build the error context first
      final context = errorContext
          .withCategory(ErrorCategory.validation)
          .withSeverity(ErrorSeverity.warning)
          .withValidationErrors(['$paramName is required']).build();

      // Then throw a properly constructed AppError
      throw AppError(
        title: 'Validation Error',
        message: '$paramName is required',
        category: ErrorCategory.validation,
        severity: ErrorSeverity.warning,
        context: context.toMap(),
      );
    }
    return value;
  }
}
