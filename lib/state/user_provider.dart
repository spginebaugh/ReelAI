import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/user_storage_service.dart';

part 'user_provider.g.dart';

@riverpod
UserService userService(UserServiceRef ref) => UserService(
      firestoreService: ref.watch(firestoreServiceProvider),
      userStorageService: ref.watch(userStorageServiceProvider),
    );

@riverpod
Stream<User?> currentUser(CurrentUserRef ref) {
  final authService = ref.watch(authServiceProvider);
  final userService = ref.watch(userServiceProvider);

  return authService.authStateChanges.asyncMap((firebaseUser) async {
    if (firebaseUser == null) return null;

    final user = await userService.getUser(firebaseUser.uid);
    return user;
  });
}

@riverpod
class UserNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> createOrUpdateUser({
    required String username,
    required String email,
  }) async {
    final authUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) throw Exception('No authenticated user found');

    final now = DateTime.now();
    final user = User(
      id: authUser.uid,
      username: username,
      email: email,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(userServiceProvider).createUser(user);
  }

  Future<void> updateProfile({
    required String username,
    String? bio,
  }) async {
    final authUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) throw Exception('No authenticated user found');

    // Get current user to preserve existing data
    final currentUserData =
        await ref.read(userServiceProvider).getUser(authUser.uid);
    if (currentUserData == null) throw Exception('User data not found');

    // Create updated user model
    final updatedUser = currentUserData.copyWith(
      username: username,
      bio: bio,
      updatedAt: DateTime.now(),
    );

    // Use the model's toJson to ensure consistent timestamp handling
    await ref.read(userServiceProvider).updateUser(
          authUser.uid,
          updatedUser.toJson(),
        );
  }
}

@riverpod
Stream<User?> userProfile(UserProfileRef ref, String userId) {
  final firestore = FirebaseFirestore.instance;
  return firestore.collection('users').doc(userId).snapshots().map(
      (doc) => doc.exists ? User.fromJson(doc.data()!..['id'] = doc.id) : null);
}

@riverpod
Future<User?> getUser(GetUserRef ref, String userId) {
  return ref.watch(userServiceProvider).getUser(userId);
}
