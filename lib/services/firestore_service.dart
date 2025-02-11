import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../models/video.dart';
import 'base_service.dart';
import '../utils/error_handler.dart';
import '../utils/transaction_decorator.dart';
import '../utils/transaction_middleware.dart';
import '../utils/logger.dart';
import '../utils/json_utils.dart';

part 'firestore_service.g.dart';

@riverpod
FirestoreService firestoreService(FirestoreServiceRef ref) =>
    FirestoreService();

class FirestoreService extends BaseService {
  final _firestore = FirebaseFirestore.instance;

  // User Operations
  @WithTransaction(
    category: ErrorCategory.database,
    middleware: [AsyncTrackingMiddleware, StateTrackingMiddleware],
  )
  Future<void> createUser(User user) async {
    await executeOperation(
      operation: () =>
          _firestore.collection('users').doc(user.id).set(user.toJson()),
      operationName: 'createUser',
      context: {'userId': user.id},
      errorCategory: ErrorCategory.database,
    );
  }

  @WithTransaction(
    category: ErrorCategory.database,
    middleware: [AsyncTrackingMiddleware],
  )
  Future<User?> getUser(String userId) async {
    return executeOperation(
      operation: () async {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (!doc.exists) return null;

        // Get raw data and ensure id is set
        final data = doc.data()!;
        data['id'] = doc.id;

        // Convert to User model
        return User.fromJson(data);
      },
      operationName: 'getUser',
      context: {'userId': userId},
      errorCategory: ErrorCategory.database,
    );
  }

  @WithTransaction(
    category: ErrorCategory.database,
    middleware: [AsyncTrackingMiddleware, StateTrackingMiddleware],
  )
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await executeOperation(
      operation: () => _firestore.collection('users').doc(userId).update(data),
      operationName: 'updateUser',
      context: {'userId': userId, 'updateFields': data.keys.toList()},
      errorCategory: ErrorCategory.database,
    );
  }

  // Video Operations
  DocumentReference generateVideoId() {
    return _firestore.collection('videos').doc();
  }

  @WithTransaction(
    category: ErrorCategory.database,
    middleware: [AsyncTrackingMiddleware, StateTrackingMiddleware],
  )
  Future<String> createVideo(Map<String, dynamic> videoData,
      [DocumentReference? docRef]) async {
    return executeOperation(
      operation: () async {
        final doc = docRef ?? generateVideoId();
        await doc.set(videoData);
        return doc.id;
      },
      operationName: 'createVideo',
      context: {'videoData': videoData},
      errorCategory: ErrorCategory.database,
    );
  }

  @WithTransaction(
    category: ErrorCategory.database,
    middleware: [AsyncTrackingMiddleware],
  )
  Future<Video?> getVideo(String videoId) async {
    return executeOperation(
      operation: () async {
        final doc = await _firestore.collection('videos').doc(videoId).get();
        if (!doc.exists) return null;

        // Get raw data and ensure id is set
        final data = doc.data()!;
        data['id'] = doc.id;

        // Convert to Video model
        return Video.fromJson(data);
      },
      operationName: 'getVideo',
      context: {'videoId': videoId},
      errorCategory: ErrorCategory.database,
    );
  }

  @WithTransaction(
    category: ErrorCategory.database,
    middleware: [AsyncTrackingMiddleware, StateTrackingMiddleware],
  )
  Stream<List<Video>> getPublicVideos() {
    return _firestore
        .collection('videos')
        .where('privacy', isEqualTo: 'public')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Video.fromJson(data);
            }).toList());
  }

  @WithTransaction(
    category: ErrorCategory.database,
    middleware: [AsyncTrackingMiddleware],
  )
  Stream<List<Video>> getUserVideos(String userId) {
    Logger.debug('Starting getUserVideos query', {
      'userId': userId,
      'collection': 'videos',
      'conditions': {
        'userId': userId,
        'isDeleted': false,
        'orderBy': 'createdAt (descending)',
      },
    });

    return _firestore
        .collection('videos')
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      Logger.debug('Received videos snapshot', {
        'userId': userId,
        'documentCount': snapshot.docs.length,
        'documents': snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'userId': data['userId'],
            'isDeleted': data['isDeleted'],
            'createdAt': data['createdAt']?.toDate().toString(),
            'allFields': data.keys.toList(),
          };
        }).toList(),
      });

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Video.fromJson(data);
      }).toList();
    });
  }

  @WithTransaction(
    category: ErrorCategory.database,
    middleware: [AsyncTrackingMiddleware, StateTrackingMiddleware],
  )
  Future<void> updateVideo(String videoId, Map<String, dynamic> data) async {
    await executeOperation(
      operation: () =>
          _firestore.collection('videos').doc(videoId).update(data),
      operationName: 'updateVideo',
      context: {'videoId': videoId, 'updateFields': data.keys.toList()},
      errorCategory: ErrorCategory.database,
    );
  }

  @WithTransaction(
    category: ErrorCategory.database,
    middleware: [AsyncTrackingMiddleware, StateTrackingMiddleware],
  )
  Future<void> deleteVideo(String videoId) async {
    await executeOperation(
      operation: () => _firestore
          .collection('videos')
          .doc(videoId)
          .update({'isDeleted': true}),
      operationName: 'deleteVideo',
      context: {'videoId': videoId},
      errorCategory: ErrorCategory.database,
    );
  }

  // Analytics Updates
  @WithTransaction(
    category: ErrorCategory.database,
    middleware: [AsyncTrackingMiddleware, StateTrackingMiddleware],
  )
  Future<void> incrementVideoLikes(String videoId) async {
    await executeOperation(
      operation: () => _firestore.collection('videos').doc(videoId).update({
        'likesCount': FieldValue.increment(1),
      }),
      operationName: 'incrementVideoLikes',
      context: {'videoId': videoId},
      errorCategory: ErrorCategory.database,
    );
  }

  @WithTransaction(
    category: ErrorCategory.database,
    middleware: [AsyncTrackingMiddleware, StateTrackingMiddleware],
  )
  Future<void> incrementVideoComments(String videoId) async {
    await executeOperation(
      operation: () => _firestore.collection('videos').doc(videoId).update({
        'commentsCount': FieldValue.increment(1),
      }),
      operationName: 'incrementVideoComments',
      context: {'videoId': videoId},
      errorCategory: ErrorCategory.database,
    );
  }
}
