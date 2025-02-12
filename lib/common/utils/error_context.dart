import 'error_handler.dart';
import 'transaction_context.dart';

/// Represents a structured error context with detailed information
class ErrorContext {
  final String operationId;
  final ErrorCategory category;
  final ErrorSeverity severity;
  final Map<String, dynamic> metadata;
  final List<String> breadcrumbs;
  final Map<String, dynamic> state;
  final List<String> validationErrors;
  final Map<String, dynamic> resourceIds;
  final TransactionContext? transactionContext;

  const ErrorContext._({
    required this.operationId,
    required this.category,
    required this.severity,
    required this.metadata,
    required this.breadcrumbs,
    required this.state,
    required this.validationErrors,
    required this.resourceIds,
    this.transactionContext,
  });

  /// Converts the error context to a map for logging
  Map<String, dynamic> toMap() {
    return {
      'operationId': operationId,
      'category': category.name,
      'severity': severity.name,
      'metadata': metadata,
      'breadcrumbs': breadcrumbs,
      'state': state,
      if (validationErrors.isNotEmpty) 'validationErrors': validationErrors,
      if (resourceIds.isNotEmpty) 'resourceIds': resourceIds,
      if (transactionContext != null)
        'transaction': transactionContext!.toMap(),
    };
  }
}

/// Builder for creating structured error contexts
class ErrorContextBuilder {
  String? _operationId;
  ErrorCategory _category = ErrorCategory.unknown;
  ErrorSeverity _severity = ErrorSeverity.error;
  final Map<String, dynamic> _metadata = {};
  final List<String> _breadcrumbs = [];
  final Map<String, dynamic> _state = {};
  final List<String> _validationErrors = [];
  final Map<String, dynamic> _resourceIds = {};
  TransactionContext? _transactionContext;

  /// Sets the operation ID
  ErrorContextBuilder withOperationId(String operationId) {
    _operationId = operationId;
    return this;
  }

  /// Sets the error category
  ErrorContextBuilder withCategory(ErrorCategory category) {
    _category = category;
    return this;
  }

  /// Sets the error severity
  ErrorContextBuilder withSeverity(ErrorSeverity severity) {
    _severity = severity;
    return this;
  }

  /// Adds metadata to the error context
  ErrorContextBuilder withMetadata(Map<String, dynamic> metadata) {
    _metadata.addAll(metadata);
    return this;
  }

  /// Adds a breadcrumb to track the error's context
  ErrorContextBuilder addBreadcrumb(String breadcrumb) {
    _breadcrumbs.add(breadcrumb);
    return this;
  }

  /// Adds state information to the error context
  ErrorContextBuilder withState(Map<String, dynamic> state) {
    _state.addAll(state);
    return this;
  }

  /// Adds validation errors to the error context
  ErrorContextBuilder withValidationErrors(List<String> errors) {
    _validationErrors.addAll(errors);
    return this;
  }

  /// Adds resource IDs to the error context
  ErrorContextBuilder withResourceIds(Map<String, dynamic> ids) {
    _resourceIds.addAll(ids);
    return this;
  }

  /// Sets the transaction context
  ErrorContextBuilder withTransactionContext(TransactionContext context) {
    _transactionContext = context;
    return this;
  }

  /// Creates an AppError with the built context
  AppError buildError({
    required String title,
    required String message,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    final context = build();

    return AppError(
      title: title,
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      category: context.category,
      severity: context.severity,
      code: context.operationId,
      context: context.toMap(),
    );
  }

  /// Builds the error context
  ErrorContext build() {
    if (_operationId == null) {
      _operationId = _transactionContext?.id ?? 'unknown';
    }

    return ErrorContext._(
      operationId: _operationId!,
      category: _category,
      severity: _severity,
      metadata: Map.unmodifiable(_metadata),
      breadcrumbs: List.unmodifiable(_breadcrumbs),
      state: Map.unmodifiable(_state),
      validationErrors: List.unmodifiable(_validationErrors),
      resourceIds: Map.unmodifiable(_resourceIds),
      transactionContext: _transactionContext,
    );
  }

  /// Creates a builder from a transaction context
  static ErrorContextBuilder fromTransaction(TransactionContext context) {
    return ErrorContextBuilder()
      ..withOperationId(context.id)
      ..withCategory(context.category)
      ..withMetadata(context.metadata)
      ..withTransactionContext(context)
      .._breadcrumbs.addAll(context.breadcrumbs);
  }
}
