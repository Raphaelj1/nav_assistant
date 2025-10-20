import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _onboardingKey = 'hasOnboarded';
  static const _voiceRateKey = 'voiceRate';
  static const _ttsEnabledKey = 'ttsEnabled';

  Future<bool> getOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<void> setOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, value);
  }

  Future<double> getVoiceRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_voiceRateKey) ?? 0.5;
  }

  Future<void> setVoiceRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_voiceRateKey, rate);
  }

  Future<bool> isHapticEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_ttsEnabledKey) ?? true;
  }

  Future<void> setHapticEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ttsEnabledKey, enabled);
  }
}
