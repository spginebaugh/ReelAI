import 'package:meta/meta.dart';
import 'error_handler.dart';
import 'transaction_context.dart';
import 'logger.dart';

/// Annotation for marking methods with transaction information
class WithTransaction {
  final String? name;
  final ErrorCategory category;
  final Map<String, dynamic>? metadata;
  final List<Type>? middleware;

  const WithTransaction({
    this.name,
    required this.category,
    this.metadata,
    this.middleware,
  });
}

/// Base class for transaction middleware
abstract class TransactionMiddleware {
  /// Called before the transaction starts
  Future<void> onStart(TransactionContext context) async {}

  /// Called after the transaction successfully completes
  Future<void> onSuccess(TransactionContext context, dynamic result) async {}

  /// Called when the transaction fails
  Future<void> onError(
    TransactionContext context,
    Object error,
    StackTrace stackTrace,
  ) async {}

  /// Called after the transaction completes (success or failure)
  Future<void> onComplete(TransactionContext context) async {}
}

/// Manages transaction decorators and middleware
class TransactionDecorator {
  static final Map<Type, TransactionMiddleware> _middleware = {};

  /// Registers a middleware instance
  static void registerMiddleware(TransactionMiddleware middleware) {
    _middleware[middleware.runtimeType] = middleware;
  }

  /// Wraps a function with transaction handling and middleware
  static Future<T> wrap<T>({
    required Future<T> Function() operation,
    required String operationName,
    required ErrorCategory category,
    Map<String, dynamic>? metadata,
    List<Type>? middleware,
  }) async {
    final transaction = TransactionManager.startTransaction(
      operationName,
      category: category,
      metadata: metadata,
    );

    // Get middleware instances
    final middlewareInstances = middleware
            ?.map((type) => _middleware[type])
            .whereType<TransactionMiddleware>()
            .toList() ??
        [];

    try {
      // Execute onStart for all middleware
      for (final m in middlewareInstances) {
        await m.onStart(transaction);
      }

      // Execute the operation
      final result = await operation();

      // Execute onSuccess for all middleware
      for (final m in middlewareInstances) {
        await m.onSuccess(transaction, result);
      }

      return result;
    } catch (error, stackTrace) {
      // Execute onError for all middleware
      for (final m in middlewareInstances) {
        await m.onError(transaction, error, stackTrace);
      }
      rethrow;
    } finally {
      // Execute onComplete for all middleware
      for (final m in middlewareInstances) {
        await m.onComplete(transaction);
      }
      TransactionManager.endTransaction(transaction.id);
    }
  }
}

/// Example middleware implementations

/// Logs detailed timing information for transactions
class TimingMiddleware extends TransactionMiddleware {
  @override
  Future<void> onComplete(TransactionContext context) async {
    Logger.performance(
      'Transaction timing',
      {
        'operationName': context.operationName,
        'duration': context.duration.inMilliseconds,
      },
    );
  }
}

/// Tracks transaction dependencies and relationships
class DependencyTrackingMiddleware extends TransactionMiddleware {
  static final Map<String, Set<String>> _dependencies = {};

  @override
  Future<void> onStart(TransactionContext context) async {
    final parentId = context.parentTransactionId;
    if (parentId != null) {
      _dependencies.putIfAbsent(parentId, () => {}).add(context.id);
    }
  }

  @override
  Future<void> onComplete(TransactionContext context) async {
    Logger.debug(
      'Transaction dependencies',
      {
        'transactionId': context.id,
        'dependencies': _dependencies[context.id]?.toList() ?? [],
      },
    );
  }
}

/// Tracks resource usage during transactions
class ResourceTrackingMiddleware extends TransactionMiddleware {
  final Map<String, int> _resourceCounts = {};

  @override
  Future<void> onStart(TransactionContext context) async {
    _resourceCounts.clear();
  }

  void trackResource(String resourceType) {
    _resourceCounts[resourceType] = (_resourceCounts[resourceType] ?? 0) + 1;
  }

  @override
  Future<void> onComplete(TransactionContext context) async {
    if (_resourceCounts.isNotEmpty) {
      Logger.debug(
        'Resource usage',
        {
          'transactionId': context.id,
          'resources': _resourceCounts,
        },
      );
    }
  }
}
