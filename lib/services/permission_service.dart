import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  static Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  static Future<bool> requestAllPermissions() async {
    var mic = await requestMicPermission();
    var cam = await requestCameraPermission();
    return mic && cam;
  }
}