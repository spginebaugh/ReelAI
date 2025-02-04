import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../models/video.dart';

part 'firestore_service.g.dart';

@riverpod
FirestoreService firestoreService(FirestoreServiceRef ref) =>
    FirestoreService();

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  // User Operations
  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<User?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return User.fromJson(doc.data()!..['id'] = doc.id);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // Video Operations
  Future<String> createVideo(Video video) async {
    // Create a new document reference with auto-generated ID
    final docRef = _firestore.collection('videos').doc();

    // Create a new video object with the generated ID
    final videoWithId = video.copyWith(id: docRef.id);

    // Set the document data with the ID included
    await docRef.set(videoWithId.toJson());

    return docRef.id;
  }

  Future<Video?> getVideo(String videoId) async {
    final doc = await _firestore.collection('videos').doc(videoId).get();
    if (!doc.exists) return null;
    return Video.fromJson(doc.data()!..['id'] = doc.id);
  }

  Future<void> updateVideo(String videoId, Map<String, dynamic> data) async {
    await _firestore.collection('videos').doc(videoId).update(data);
  }

  Future<void> deleteVideo(String videoId) async {
    await _firestore.collection('videos').doc(videoId).delete();
  }

  // Queries
  Stream<List<Video>> getUserVideos(String userId) {
    return _firestore
        .collection('videos')
        .where('uploaderId', isEqualTo: userId)
        .orderBy('uploadTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Video.fromJson(doc.data()..['id'] = doc.id))
            .toList());
  }

  Stream<List<Video>> getPublicVideos() {
    return _firestore
        .collection('videos')
        .where('privacy', isEqualTo: 'public')
        .orderBy('uploadTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Video.fromJson(doc.data()..['id'] = doc.id))
            .toList());
  }

  // Analytics Updates
  Future<void> incrementVideoLikes(String videoId) async {
    await _firestore.collection('videos').doc(videoId).update({
      'likesCount': FieldValue.increment(1),
    });
  }

  Future<void> incrementVideoComments(String videoId) async {
    await _firestore.collection('videos').doc(videoId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }
}
