import 'package:rhino_flutter/rhino.dart';
import 'package:rhino_flutter/rhino_error.dart';
import 'package:rhino_flutter/rhino_manager.dart';
import 'package:nav_assistant/constants/config.dart';

class SpeechToIntentService {
  SpeechToIntentService._internal();
  static final SpeechToIntentService _instance =
      SpeechToIntentService._internal();
  factory SpeechToIntentService() {
    return _instance;
  }

  RhinoManager? _rhinoManager;
  bool _isInitialized = false;

  Function(String intent)? onIntentRecognized;
  Function()? onIntentNotRecognized;

  Future<void> init({String? accessKey, String? contextPath}) async {
    if (_isInitialized) return;

    try {
      _rhinoManager = await RhinoManager.create(
        AppConfig.picovoiceApiKey,
        'assets/voice_control/speech_to_intent_navi_android.rhn',
        _inferenceCallback,
        sensitivity: 0.7,
        processErrorCallback: _onError,
      );

      _isInitialized = true;
    } catch (e) {
      throw Exception("Rhino initialization failed: $e");
    }
  }

  void _inferenceCallback(RhinoInference inference) {
    if (inference.isUnderstood == true) {
      var intent = inference.intent;
      // print("Inference intent: $intent"); // debugging

      if (onIntentRecognized != null) {
        onIntentRecognized!(intent!);
      }
    } else {
      // print("Intent is not understood"); // debugging
      if (onIntentNotRecognized != null) {
        onIntentNotRecognized!();
      }
    }
  }

  void _onError(RhinoException e) {
    throw Exception("Rhino Error: ${e.message}");
  }

  Future<void> start() async {
    if (!_isInitialized) await init();
    await _rhinoManager?.process();
  }

  Future<void> stop() async {
    // await _rhinoManager?.stop();
  }

  Future<void> dispose() async {
    await _rhinoManager?.delete();
    _isInitialized = false;
    _rhinoManager = null;
  }
}
