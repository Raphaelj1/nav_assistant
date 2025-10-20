import 'package:nav_assistant/storage/preferences_service.dart';

class SettingsController {
  final _prefs = PreferencesService();

  Future<bool> loadHapticSetting() => _prefs.isHapticEnabled();
  Future<void> saveHapticSetting(bool enabled) => _prefs.setHapticEnabled(enabled);

  Future<double> loadVoiceRate() => _prefs.getVoiceRate();
  Future<void> saveVoiceRate(double rate) => _prefs.setVoiceRate(rate);
}
