import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reel_ai/services/auth_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
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
    state = await AsyncValue.guard(() => ref
        .read(authServiceProvider)
        .signInWithEmailAndPassword(email: email, password: password));
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref
        .read(authServiceProvider)
        .createUserWithEmailAndPassword(email: email, password: password));
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() => ref.read(authServiceProvider).signOut());
  }
}
