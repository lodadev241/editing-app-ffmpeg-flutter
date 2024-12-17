import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class StorageUtils {

  static Future<bool> requestStoragePermissions() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final sdk = deviceInfo.version.sdkInt;
    if (sdk <= 32) {
      final request = Permission.storage.request();
      if (await request.isGranted) {
        return true;
      }
    } else {
      final request = Permission.photos.request();
      if (await request.isGranted) {
        return true;
      }
    }
    return false;
  }
  
}
