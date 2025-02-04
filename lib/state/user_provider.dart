import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

part 'user_provider.g.dart';

@riverpod
class CurrentUser extends _$CurrentUser {
  String? _tempBio;

  String? get tempBio => _tempBio;
  set tempBio(String? value) => _tempBio = value;

  @override
  Future<User?> build() async {
    _tempBio = null; // Reset temp bio when rebuilding
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) return null;

    return ref.read(firestoreServiceProvider).getUser(authUser.uid);
  }

  Future<void> createOrUpdateUser({
    required String username,
    required String email,
    String? profilePictureUrl,
    String? bio,
  }) async {
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) throw Exception('No authenticated user found');

    final user = User(
      id: authUser.uid,
      username: username,
      email: email,
      profilePictureUrl: profilePictureUrl,
      bio: bio,
      createdAt: DateTime.now(),
    );

    await ref.read(firestoreServiceProvider).createUser(user);
    state = AsyncValue.data(user);
  }

  Future<void> updateProfile({
    String? username,
    String? bio,
    String? profilePictureUrl,
  }) async {
    final user = state.value;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (bio != null) updates['bio'] = bio;
    if (profilePictureUrl != null)
      updates['profilePictureUrl'] = profilePictureUrl;

    await ref.read(firestoreServiceProvider).updateUser(user.id, updates);
    state = AsyncValue.data(user.copyWith(
      username: username ?? user.username,
      bio: bio ?? user.bio,
      profilePictureUrl: profilePictureUrl ?? user.profilePictureUrl,
    ));
  }
}

@riverpod
Stream<User?> userProfile(UserProfileRef ref, String userId) {
  final firestore = FirebaseFirestore.instance;
  return firestore.collection('users').doc(userId).snapshots().map(
      (doc) => doc.exists ? User.fromJson(doc.data()!..['id'] = doc.id) : null);
}
