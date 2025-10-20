import 'package:flutter_tts/flutter_tts.dart';
import '../../storage/preferences_service.dart';

class TtsService {
  TtsService._internal();

  static final TtsService _instance = TtsService._internal();

  factory TtsService() {
    return _instance;
  }

  final FlutterTts _tts = FlutterTts();
  final _prefs = PreferencesService();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await _tts.setLanguage("en-US");

    // Load user-preferred speaking rate
    final rate = await _prefs.getVoiceRate();
    await _tts.setSpeechRate(rate);
    final engines = await _tts.getEngines;
    if (engines.isEmpty) {
      print("No TTS enigine installed on this device.");
      return;
    }

    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) await init();
    await _tts.stop(); // Stop previous speech
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> setRate(double rate) async {
    await _tts.setSpeechRate(rate);
    await _prefs.setVoiceRate(rate);
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
