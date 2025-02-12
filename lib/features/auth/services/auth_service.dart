import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reel_ai/features/auth/providers/user_provider.dart';
import 'package:reel_ai/common/services/base_service.dart';
import 'package:reel_ai/common/utils/error_handler.dart';
import 'package:reel_ai/common/utils/transaction_decorator.dart';
import 'package:reel_ai/common/utils/transaction_middleware.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));

class AuthService extends BaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref _ref;

  AuthService(this._ref);

  // Stream to listen to auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  @WithTransaction(
    category: ErrorCategory.auth,
    middleware: [
      AsyncTrackingMiddleware,
      StateTrackingMiddleware,
      NetworkTrackingMiddleware,
    ],
  )
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {'email': email, 'password': password},
          validators: {
            'email': (value) =>
                value?.toString().isEmpty == true ? 'Email is required' : '',
            'password': (value) =>
                value?.toString().isEmpty == true ? 'Password is required' : '',
          },
        );

        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Create user in Firestore
        if (credential.user != null) {
          final username = email.split('@')[0]; // Default username from email
          await _ref.read(userNotifierProvider.notifier).createOrUpdateUser(
                username: username,
                email: email,
              );
        }

        return credential;
      },
      operationName: 'createUserWithEmailAndPassword',
      context: {'email': email},
      errorCategory: ErrorCategory.auth,
    );
  }

  @WithTransaction(
    category: ErrorCategory.auth,
    middleware: [
      AsyncTrackingMiddleware,
      StateTrackingMiddleware,
      NetworkTrackingMiddleware,
    ],
  )
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {'email': email, 'password': password},
          validators: {
            'email': (value) =>
                value?.toString().isEmpty == true ? 'Email is required' : '',
            'password': (value) =>
                value?.toString().isEmpty == true ? 'Password is required' : '',
          },
        );

        return await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      },
      operationName: 'signInWithEmailAndPassword',
      context: {'email': email},
      errorCategory: ErrorCategory.auth,
    );
  }

  @WithTransaction(
    category: ErrorCategory.auth,
    middleware: [AsyncTrackingMiddleware, StateTrackingMiddleware],
  )
  Future<void> signOut() async {
    await executeOperation(
      operation: () => _auth.signOut(),
      operationName: 'signOut',
      errorCategory: ErrorCategory.auth,
    );
  }
}
