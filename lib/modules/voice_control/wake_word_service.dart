// import 'package:flutter/foundation.dart';
import 'package:nav_assistant/constants/config.dart';
import 'package:porcupine_flutter/porcupine_error.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';

class WakeWordService {
  WakeWordService._internal();
  static final WakeWordService _instance = WakeWordService._internal();
  factory WakeWordService() {
    return _instance;
  }

  PorcupineManager? _manager;
  bool _isInitialized = false;
  bool _isListening = false;

  // VoidCallback? onWakeWordDetected;
  Function? onWakeWordDetected;

  Future<void> init({
    String? accessKey = '',
    List<String>? keywordPaths = const [''],
  }) async {
    if (_isInitialized) return;

    try {
      _manager = await PorcupineManager.fromKeywordPaths(
        AppConfig.picovoiceApiKey,
        ['assets/voice_control/hey-navi_android.ppn'],
        _wakeWordCallback,
        errorCallback: _onError,
      );

      _isInitialized = true;
    } catch (e) {
      throw Exception("Porcupine initialization failed: $e");
    }
  }

  void _wakeWordCallback(int keywordIndex) {
      onWakeWordDetected?.call();
  }

  void _onError(PorcupineException e) {
    throw Exception("Porcupine Error: ${e.message}");
  }

  Future<void> start() async {
    if (!_isInitialized) await init();
    if (_isListening) return;

    await _manager!.start();
    _isListening = true;
  }

  Future<void> stop() async {
    if (_manager == null || !_isListening) return;
    await _manager!.stop();
    _isListening = false;
  }

  Future<void> dispose() async {
    await stop();
    await _manager?.delete();
    _isInitialized = false;
    _isListening = false;
    _manager = null;
  }
}
