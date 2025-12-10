import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload avatar with compression and return download URL
  Future<String> uploadAvatar(String uid, File imageFile) async {
    try {
      // Compress image before uploading
      final compressedFile = await _compressImage(imageFile);

      // Upload to Firebase Storage
      final ref = _storage.ref().child('avatars/$uid.jpg');
      final uploadTask = await ref.putFile(
        compressedFile ?? imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'no-cache, no-store, must-revalidate',
        ),
      );

      // Generate fresh download URL with timestamp to avoid caching
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '$downloadUrl?t=$timestamp';
    } catch (e) {
      throw Exception('Failed to upload avatar');
    }
  }

  /// Compress image to reduce file size
  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'compressed_${path.basename(file.path)}',
      );

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 800,
        minHeight: 800,
      );

      return compressedFile != null ? File(compressedFile.path) : null;
    } catch (e) {
      // If compression fails, return original file
      return null;
    }
  }

  /// Delete avatar
  Future<void> deleteAvatar(String uid) async {
    try {
      final ref = _storage.ref().child('avatars/$uid.jpg');
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
    }
  }
}
