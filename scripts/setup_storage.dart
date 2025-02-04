import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  final storage = FirebaseStorage.instance;

  // Create default public assets
  final defaultAssets = {
    'default_avatar.jpg': 'assets/defaults/default_avatar.jpg',
    'default_thumbnail.jpg': 'assets/defaults/default_thumbnail.jpg',
  };

  // Upload default assets
  for (final asset in defaultAssets.entries) {
    final file = File(asset.value);
    if (await file.exists()) {
      final ref = storage.ref('public/assets/${asset.key}');
      await ref.putFile(file);
      print('Uploaded ${asset.key}');
    } else {
      print('Warning: ${asset.value} not found');
    }
  }

  print('Storage structure setup complete!');
  exit(0);
}
