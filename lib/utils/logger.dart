import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

enum LogLevel {
  debug('🐛'),
  info('ℹ️'),
  warning('⚠️'),
  error('❌'),
  success('✅'),
  network('🌐'),
  storage('💾'),
  video('🎥'),
  audio('🔊'),
  subtitle('📝'),
  state('📊'),
  performance('⚡');

  final String emoji;
  const LogLevel(this.emoji);
}

class Logger {
  static bool _enabled = true;
  static const String _divider = '----------------------------------------';

  // Context and transaction tracking
  static final Map<String, dynamic> _context = {};
  static String? _currentTransactionId;
  static final Map<String, int> _transactionStartTimes = {};
  static const _uuid = Uuid();

  // Performance tracking
  static final Map<String, List<Duration>> _performanceMetrics = {};
  static const int _maxMetricsPerOperation = 100;

  static void enable() => _enabled = true;
  static void disable() => _enabled = false;

  /// Sets global context that will be included with all log messages
  static void setGlobalContext(Map<String, dynamic> context) {
    _context.addAll(context);
  }

  /// Clears all global context
  static void clearGlobalContext() {
    _context.clear();
  }

  /// Starts a new transaction with optional context
  static String startTransaction(String name, [Map<String, dynamic>? context]) {
    final transactionId = _uuid.v4();
    _currentTransactionId = transactionId;
    _transactionStartTimes[transactionId] =
        DateTime.now().millisecondsSinceEpoch;

    if (context != null) {
      _context['transaction_$transactionId'] = context;
    }

    debug('Started transaction: $name', {
      'transactionId': transactionId,
      ...?context,
    });

    return transactionId;
  }

  /// Ends the current transaction and logs its duration
  static void endTransaction(String transactionId) {
    final startTime = _transactionStartTimes[transactionId];
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      performance('Transaction completed', {
        'transactionId': transactionId,
        'duration': '${duration}ms',
      });

      _transactionStartTimes.remove(transactionId);
      _context.remove('transaction_$transactionId');

      if (transactionId == _currentTransactionId) {
        _currentTransactionId = null;
      }
    }
  }

  /// Records a performance metric for an operation
  static void recordMetric(String operation, Duration duration) {
    if (!_performanceMetrics.containsKey(operation)) {
      _performanceMetrics[operation] = [];
    }

    final metrics = _performanceMetrics[operation]!;
    metrics.add(duration);

    // Keep only the last N metrics
    if (metrics.length > _maxMetricsPerOperation) {
      metrics.removeAt(0);
    }

    performance('Performance metric recorded', {
      'operation': operation,
      'duration': '${duration.inMilliseconds}ms',
      'average': '${_calculateAverageMetric(operation).inMilliseconds}ms',
    });
  }

  /// Calculates the average duration for an operation
  static Duration _calculateAverageMetric(String operation) {
    final metrics = _performanceMetrics[operation];
    if (metrics == null || metrics.isEmpty) return Duration.zero;

    final total = metrics.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    return Duration(milliseconds: total ~/ metrics.length);
  }

  static void _log(LogLevel level, String message, [Object? details]) {
    if (!_enabled || !kDebugMode) return;

    final timestamp = DateTime.now().toIso8601String();
    final Map<String, dynamic> logData = {
      'timestamp': timestamp,
      'level': level.name,
      'message': message,
      if (_currentTransactionId != null) 'transactionId': _currentTransactionId,
      ..._context,
    };

    if (details != null) {
      if (details is Map) {
        logData['details'] = details;
      } else {
        logData['details'] = details.toString();
      }
    }

    final logMessage = '${level.emoji} $message';
    final logDetails = _formatLogData(logData);

    debugPrint('$logMessage\n$logDetails');
  }

  static String _formatLogData(Map<String, dynamic> data) {
    const encoder = JsonEncoder.withIndent('  ');
    return _divider + '\n' + encoder.convert(data) + '\n' + _divider;
  }

  // Logging methods with transaction and context support
  static void debug(String message, [Object? details]) =>
      _log(LogLevel.debug, message, details);

  static void info(String message, [Object? details]) =>
      _log(LogLevel.info, message, details);

  static void warning(String message, [Object? details]) =>
      _log(LogLevel.warning, message, details);

  static void error(String message, [Object? details]) =>
      _log(LogLevel.error, message, details);

  static void success(String message, [Object? details]) =>
      _log(LogLevel.success, message, details);

  static void network(String message, [Object? details]) =>
      _log(LogLevel.network, message, details);

  static void storage(String message, [Object? details]) =>
      _log(LogLevel.storage, message, details);

  static void video(String message, [Object? details]) =>
      _log(LogLevel.video, message, details);

  static void audio(String message, [Object? details]) =>
      _log(LogLevel.audio, message, details);

  static void subtitle(String message, [Object? details]) =>
      _log(LogLevel.subtitle, message, details);

  static void state(String message, [Object? details]) =>
      _log(LogLevel.state, message, details);

  static void performance(String message, [Object? details]) =>
      _log(LogLevel.performance, message, details);

  // Enhanced group logging with transaction support
  static T? group<T>(String groupName, T Function() logFunction) {
    if (!_enabled || !kDebugMode) return logFunction();

    final transactionId = startTransaction(groupName);
    debugPrint('\n📎 BEGIN: $groupName');
    debugPrint(_divider);

    try {
      final result = logFunction();
      return result;
    } finally {
      debugPrint(_divider);
      debugPrint('📎 END: $groupName\n');
      endTransaction(transactionId);
    }
  }
}
