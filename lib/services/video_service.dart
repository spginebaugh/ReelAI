import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/video.dart';

class VideoService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload video to Firebase Storage
  Future<String> uploadVideo(File videoFile, String videoId) async {
    Reference ref = _storage.ref().child('videos/$videoId.mp4');
    UploadTask uploadTask = ref.putFile(videoFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Save video metadata to Firestore
  Future<void> saveVideoMetadata(Video video) async {
    await _firestore.collection('videos').doc(video.id).set(video.toMap());
  }

  // Retrieve video metadata from Firestore
  Stream<List<Video>> getVideos() {
    return _firestore.collection('videos').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Video.fromMap(doc.data())).toList());
  }
}
