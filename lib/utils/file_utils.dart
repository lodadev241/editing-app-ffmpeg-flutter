import 'dart:developer';
import 'dart:io';

import 'package:editor_app/utils/storage_utils.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:path_provider/path_provider.dart';

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

  static Future<String?> getAssetPath(String assetPath) async {
    try {
      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');

      // Copy the asset to the temporary file
      final byteData = await rootBundle.load(assetPath);
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      return tempFile.path; // Return the path to the copied file
    } catch (e) {
      log("Asset Path Error: $assetPath");
      return null;
    }
  }
}
