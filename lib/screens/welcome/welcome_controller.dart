import 'package:nav_assistant/storage/preferences_service.dart';

class WelcomeController {
  final _prefs = PreferencesService();

  Future<void> completeOnboarding() => _prefs.setOnboardingComplete();
  Future<void> setOnboarding(bool value) => _prefs.setOnboarding(value);
  
}
