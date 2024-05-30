import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MediaService {
  static final MediaService instance = MediaService._();
  final ImagePicker _picker = ImagePicker();

  MediaService._();

  Future<File?> getImageFromLibrary() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image != null ? File(image.path) : null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}
