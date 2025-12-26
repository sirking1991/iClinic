import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AttachmentHelper {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return null;

      return await _saveLocally(image);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<String> _saveLocally(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory(p.join(appDir.path, 'attachments'));

    // Ensure directory exists before saving
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
    final destinationPath = p.join(attachmentsDir.path, fileName);

    // Using saveTo which is more robust for XFile
    await file.saveTo(destinationPath);
    return destinationPath;
  }

  // Ensure directory exists
  static Future<void> ensureDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(appDir.path, 'attachments'));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } catch (e) {
      debugPrint('Error ensuring directory: $e');
    }
  }
}
