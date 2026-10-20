import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../../core/domain/domain_error.dart';
import '../domain/photo_source.dart';

class GalleryPhotoSource implements PhotoSource {
  @override
  Future<Uint8List?> pick() async {
    final file = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
    if (file == null) return null;
    require(await file.length() <= 5 * 1024 * 1024, '写真は5MB以下の画像を選んでください');
    return file.readAsBytes();
  }
}
