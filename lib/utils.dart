import 'package:shared_preferences/shared_preferences.dart';

double? parseFlexibleDouble(String? value) {
  if (value == null || value.isEmpty) return null;
  final normalized = value.startsWith('.')
      ? '0$value'
      : value.startsWith('-.')
          ? value.replaceFirst('-.', '-0.')
          : value;
  return double.tryParse(normalized);
}

/// Whether the camera permission request has been shown before.
Future<bool> wasCameraPermissionRequested() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('cameraPermissionRequested') ?? false;
}

/// Mark that the camera permission request was shown.
Future<void> markCameraPermissionRequested() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('cameraPermissionRequested', true);
}
