import 'package:uuid/uuid.dart';
import 'error_handler.dart';
import 'logger.dart';

/// Represents the context of a transaction in the application
class TransactionContext {
  final String id;
  final String operationName;
  final ErrorCategory category;
  final DateTime startTime;
  final String? parentTransactionId;
  final int depth;
  final Map<String, dynamic> metadata;
  final List<String> breadcrumbs;

  TransactionContext._({
    String? id,
    required this.operationName,
    required this.category,
    DateTime? startTime,
    this.parentTransactionId,
    this.depth = 0,
    Map<String, dynamic>? metadata,
    List<String>? breadcrumbs,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now(),
        metadata = Map.unmodifiable(metadata ?? {}),
        breadcrumbs = List.unmodifiable(breadcrumbs ?? []);

  /// Creates a child transaction context inheriting from the current context
  TransactionContext createChild(
    String operationName, {
    ErrorCategory? category,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionContext._(
      operationName: operationName,
      category: category ?? this.category,
      parentTransactionId: id,
      depth: depth + 1,
      metadata: {
        ...this.metadata,
        ...?metadata,
      },
      breadcrumbs: [...breadcrumbs],
    );
  }

  /// Adds a breadcrumb to track the transaction's progress
  TransactionContext addBreadcrumb(String breadcrumb) {
    return TransactionContext._(
      id: id,
      operationName: operationName,
      category: category,
      startTime: startTime,
      parentTransactionId: parentTransactionId,
      depth: depth,
      metadata: metadata,
      breadcrumbs: [...breadcrumbs, breadcrumb],
    );
  }

  /// Creates a new transaction context
  static TransactionContext create(
    String operationName, {
    required ErrorCategory category,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionContext._(
      operationName: operationName,
      category: category,
      metadata: metadata,
    );
  }

  /// Duration since the transaction started
  Duration get duration => DateTime.now().difference(startTime);

  /// Converts the context to a map for logging
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operationName': operationName,
      'category': category.name,
      'startTime': startTime.toIso8601String(),
      'duration': duration.inMilliseconds,
      if (parentTransactionId != null)
        'parentTransactionId': parentTransactionId,
      'depth': depth,
      'metadata': metadata,
      'breadcrumbs': breadcrumbs,
    };
  }
}

/// Manages the lifecycle of a transaction
class TransactionManager {
  static final Map<String, TransactionContext> _activeTransactions = {};
  static TransactionContext? _currentTransaction;

  /// Starts a new transaction
  static TransactionContext startTransaction(
    String operationName, {
    required ErrorCategory category,
    Map<String, dynamic>? metadata,
  }) {
    final transaction = _currentTransaction?.createChild(
          operationName,
          category: category,
          metadata: metadata,
        ) ??
        TransactionContext.create(
          operationName,
          category: category,
          metadata: metadata,
        );

    _activeTransactions[transaction.id] = transaction;
    _currentTransaction = transaction;

    Logger.debug('Started transaction', transaction.toMap());
    return transaction;
  }

  /// Ends a transaction and logs its completion
  static void endTransaction(String transactionId) {
    final transaction = _activeTransactions.remove(transactionId);
    if (transaction == null) return;

    if (_currentTransaction?.id == transactionId) {
      _currentTransaction =
          _activeTransactions[transaction.parentTransactionId];
    }

    Logger.debug('Ended transaction', transaction.toMap());
  }

  /// Gets the current transaction context
  static TransactionContext? get currentTransaction => _currentTransaction;

  /// Cleans up all active transactions
  static void cleanup() {
    _activeTransactions.clear();
    _currentTransaction = null;
  }
}
