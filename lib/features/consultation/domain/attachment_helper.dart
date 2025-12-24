import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AttachmentHelper {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return null;

    return await _saveLocally(File(image.path));
  }

  Future<String> _saveLocally(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(file.path);
    final savedImage = await file.copy('${appDir.path}/attachments/$fileName');
    return savedImage.path;
  }
  
  // Ensure directory exists
  static Future<void> ensureDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/attachments');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }
}
