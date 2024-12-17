import 'dart:io';

import 'package:editor_app/utils/storage_utils.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class FileUtils {
  static ImagePickerPlatform imagePickerImplementation =
      ImagePickerPlatform.instance;

  static Future<File?> getVideoFromGallery() async {
    final havePermission = await StorageUtils.requestStoragePermissions();
    if (havePermission) {
      final file = await imagePickerImplementation.getVideo(
        source: ImageSource.gallery,
      );
      if (file != null) {
        return File(file.path);
      }
    }
    return null;
  }

  static void deleteFile(String filePath) {
    if (checkIfFileExists(filePath)) {
      File(filePath).deleteSync(recursive: true);
    }
  }

  static bool checkIfFileExists(String filePath) {
    return File(filePath).existsSync();
  }
}
