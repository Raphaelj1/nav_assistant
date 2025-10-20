import 'package:flutter/services.dart';
import '../../storage/preferences_service.dart';

class HapticService {
  // remove the static if they aren't working
  static final _prefs = PreferencesService();

  static Future<void> vibrate() async {
    final enabled = await _prefs.isHapticEnabled();

    if (enabled) {
      HapticFeedback.mediumImpact();
    }
  }

  static Future<void> vibrateStrong() async {
    final enabled = await _prefs.isHapticEnabled();

    if (enabled) {
      HapticFeedback.heavyImpact();
    }
  }

  static Future<void> vibrateLight() async {
    final enabled = await _prefs.isHapticEnabled();

    if (enabled) {
      HapticFeedback.lightImpact();
    }
  }
}
