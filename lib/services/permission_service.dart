import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (await Permission.audio.isGranted) {
      return true;
    }

    final status = await Permission.audio.request();
    if (status.isGranted) {
      return true;
    }

    if (await Permission.storage.isGranted) {
      return true;
    }

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    // Request notification permission for Android 13+
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
