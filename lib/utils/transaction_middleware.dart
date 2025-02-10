import 'dart:async';
import 'package:flutter/widgets.dart';
import 'transaction_decorator.dart';
import 'transaction_context.dart';
import 'logger.dart';

/// Middleware for propagating transaction context through the widget tree
class ContextPropagationMiddleware extends TransactionMiddleware {
  static final _contextZone = Zone.current;
  static TransactionContext? get currentContext =>
      _contextZone[#transactionContext] as TransactionContext?;

  @override
  Future<void> onStart(TransactionContext context) async {
    runZoned(
      () {},
      zoneValues: {#transactionContext: context},
    );
  }
}

/// Middleware for tracking async operations within a transaction
class AsyncTrackingMiddleware extends TransactionMiddleware {
  final Set<String> _pendingOperations = {};
  final _completer = Completer<void>();

  Future<void> get done => _completer.future;

  void trackAsyncOperation(String operationName) {
    _pendingOperations.add(operationName);
  }

  void completeAsyncOperation(String operationName) {
    _pendingOperations.remove(operationName);
    if (_pendingOperations.isEmpty && !_completer.isCompleted) {
      _completer.complete();
    }
  }

  @override
  Future<void> onComplete(TransactionContext context) async {
    if (_pendingOperations.isNotEmpty) {
      Logger.warning(
        'Transaction completed with pending operations',
        {
          'transactionId': context.id,
          'pendingOperations': _pendingOperations.toList(),
        },
      );
    }
  }
}

/// Middleware for tracking state changes during a transaction
class StateTrackingMiddleware extends TransactionMiddleware {
  final Map<String, dynamic> _initialState = {};
  final Map<String, dynamic> _stateChanges = {};

  void trackState(String key, dynamic value) {
    if (!_initialState.containsKey(key)) {
      _initialState[key] = value;
    }
    _stateChanges[key] = value;
  }

  @override
  Future<void> onComplete(TransactionContext context) async {
    if (_stateChanges.isNotEmpty) {
      final changes = <String, Map<String, dynamic>>{};
      for (final entry in _stateChanges.entries) {
        if (_initialState[entry.key] != entry.value) {
          changes[entry.key] = {
            'from': _initialState[entry.key],
            'to': entry.value,
          };
        }
      }

      if (changes.isNotEmpty) {
        Logger.state(
          'State changes during transaction',
          {
            'transactionId': context.id,
            'changes': changes,
          },
        );
      }
    }
  }
}

/// Middleware for tracking network requests during a transaction
class NetworkTrackingMiddleware extends TransactionMiddleware {
  final List<Map<String, dynamic>> _requests = [];

  void trackRequest({
    required String url,
    required String method,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    _requests.add({
      'url': url,
      'method': method,
      'headers': headers,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> onComplete(TransactionContext context) async {
    if (_requests.isNotEmpty) {
      Logger.network(
        'Network requests during transaction',
        {
          'transactionId': context.id,
          'requests': _requests,
        },
      );
    }
  }
}

/// Widget that provides transaction context to its descendants
class TransactionContextProvider extends InheritedWidget {
  final TransactionContext context;

  const TransactionContextProvider({
    required this.context,
    required Widget child,
    super.key,
  }) : super(child: child);

  static TransactionContext? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TransactionContextProvider>()
        ?.context;
  }

  @override
  bool updateShouldNotify(TransactionContextProvider oldWidget) {
    return context.id != oldWidget.context.id;
  }
}

/// Extension method for BuildContext to easily access transaction context
extension TransactionContextX on BuildContext {
  TransactionContext? get transactionContext =>
      TransactionContextProvider.of(this);
}
