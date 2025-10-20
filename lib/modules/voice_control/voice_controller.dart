import './wake_word_service.dart';
import './speech_to_intent_service.dart';
import 'package:nav_assistant/services/permission_service.dart';

class VoiceController {
  VoiceController._internal();
  static final VoiceController _instance = VoiceController._internal();
  factory VoiceController() {
    return _instance;
  }

  final _wakeWord = WakeWordService();
  final _speechToIntent = SpeechToIntentService();

  bool _isInitialized = false;

  Function? _onWakeWord;
  Function(String intent)? _onIntent;
  Function? _onUnrecognized;

  Future<void> init({
    Function()? onWakeWord,
    required Function(String intent) onIntent,
    Function()? onUnrecognized,
  }) async {
    if (_isInitialized) return;

    _onWakeWord = onWakeWord;
    _onIntent = onIntent;
    _onUnrecognized = onUnrecognized;

    await _wakeWord.init();
    await _speechToIntent.init();

    _wakeWord.onWakeWordDetected = _handleWakeWordDetected;
    _speechToIntent.onIntentRecognized = _handleIntentRecognized;
    _speechToIntent.onIntentNotRecognized = _handleIntentNotRecognized;

    _isInitialized = true;
  }

  Future<void> _handleWakeWordDetected() async {
    await _onWakeWord?.call();
    await _switchToIntent();
  }

  Future<void> _handleIntentRecognized(String intent) async {
    if (intent.isNotEmpty) {
      _onIntent?.call(intent);
    } else {
      _onUnrecognized?.call();
    }
    await _switchToWakeWord();
  }

  Future<void> _handleIntentNotRecognized() async {
    _onUnrecognized?.call();
    _switchToWakeWord();
  }

  Future<void> start() async {
    if (!_isInitialized) {
      throw Exception("Voice controller must be initialized");
    }

    final granted = await PermissionService.requestMicPermission();
    if (!granted) {
      // use tts to tell them to enable it in settings
      throw Exception("Microphone permission not granted");
    }
    await _wakeWord.start();
  }

  Future<void> stop() async {
    await _wakeWord.stop();
  }

  Future<void> dispose() async {
    await _wakeWord.dispose();
    await _speechToIntent.dispose();
    _isInitialized = false;
  }

  // Internal switching
  Future<void> _switchToWakeWord() async {
    await _wakeWord.start();
  }

  Future<void> _switchToIntent() async {
    await _wakeWord.stop();
    await _speechToIntent.start();
  }
}
