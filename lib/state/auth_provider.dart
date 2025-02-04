import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reel_ai/services/auth_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  // Force immediate check of current auth state
  final currentUser = authService.currentUser;
  if (currentUser == null) {
    return Stream.value(null);
  }
  return authService.authStateChanges;
});

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(() {
  return AuthController();
});

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authServiceProvider)
          .signInWithEmailAndPassword(email: email, password: password);
      // Force refresh the auth state
      ref.invalidate(authStateProvider);
    });
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authServiceProvider)
          .createUserWithEmailAndPassword(email: email, password: password);
      // Force refresh the auth state
      ref.invalidate(authStateProvider);
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signOut();
      // Force refresh the auth state
      ref.invalidate(authStateProvider);
    });
  }
}
