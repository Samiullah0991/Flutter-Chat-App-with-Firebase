// cloud_storage_service.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  late FirebaseStorage _storage;
  late Reference _baseRef;

  final String _profileImages = "profile_images";
  final String _messages = "messages";
  final String _images = "images";

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage.ref();
  }

  Future<TaskSnapshot> uploadUserImage(String uid, File image) async {
    try {
      return await _baseRef.child(_profileImages).child(uid).putFile(image);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<TaskSnapshot> uploadMediaMessage(String uid, File file) async {
    var timestamp = DateTime.now();
    var fileName = basename(file.path);
    fileName = '$fileName${timestamp.toString()}'; // Remove underscore here

    try {
      return await _baseRef
          .child(_messages)
          .child(uid)
          .child(_images)
          .child(fileName)
          .putFile(file)
          .then((task) => task);
    } catch (e) {
      print(e);
      throw e; // Throw the exception to propagate it
    }
  }
}
