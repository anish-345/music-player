import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    // Android 13+ (API 33) uses READ_MEDIA_AUDIO - much safer than storage permissions
    if (Platform.isAndroid) {
      // Parse Android version - Platform.version format is like "3.10.7"
      // We need the SDK version, not the Flutter/Dart version
      final versionString = Platform.version.split(' ')[0];
      final sdkVersion = int.tryParse(versionString) ?? 33;

      if (sdkVersion >= 33) {
        // Android 13+ - just check READ_MEDIA_AUDIO
        if (await Permission.audio.isGranted) {
          return true;
        }
        final status = await Permission.audio.request();
        return status.isGranted;
      } else if (sdkVersion >= 29) {
        // Android 10-12 - scoped storage, no special permissions needed for public media
        if (await Permission.audio.isGranted) {
          return true;
        }
        final status = await Permission.audio.request();
        return status.isGranted;
      } else {
        // Android 9 and below - use storage permission
        if (await Permission.storage.isGranted) {
          return true;
        }
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  static Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final versionString = Platform.version.split(' ')[0];
      final sdkVersion = int.tryParse(versionString) ?? 33;

      // Android 13+ requires runtime notification permission
      if (sdkVersion >= 33) {
        if (await Permission.notification.isGranted) {
          return true;
        }
        final status = await Permission.notification.request();
        return status.isGranted;
      }
    }
    return true; // No notification permission needed on iOS or Android < 13
  }
}
