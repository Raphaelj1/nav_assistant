import 'package:nav_assistant/modules/feedback/tts_service.dart';
import 'package:nav_assistant/modules/voice_control/voice_controller.dart';
import 'package:nav_assistant/screens/main_ui/pipeline_controller.dart';
// import 'package:audioplayers/audioplayers.dart';

class MainController {
  final _voiceController = VoiceController();
  final _pipeline = PipelineController();
  final _tts = TtsService();
  // final _player = AudioPlayer();

  Future<void> init() async {
    await _voiceController.init(
      onWakeWord: _onWakeWord,
      onIntent: _onVoiceIntent,
      onUnrecognized: _onUnrecognized,
    );
  }

  Future<void> listen() async {
    await _voiceController.start();
  }

  Future<void> clean() async {
    await _voiceController.stop();
  }

  Future<void> _onWakeWord() async {
    // await _player.play(
    //   AssetSource('sounds/wake.wav'),
    //   mode: PlayerMode.lowLatency,
    // );
  }

  void _onUnrecognized() {
    _tts.speak("Sorry, I didn't understand the command.");
  }

  void _onVoiceIntent(String intent) {
    switch (intent) {
      case "detectObjects":
        onSingleTap();
        break;
      case "recognizeScene":
        onDoubleTap();
        break;
      case "fullPerception":
        onLongPress();
        break;
      default:
        break;
    }
  }

  void onSingleTap() {
    print("Main controller: Performing single tap");
    _pipeline.detectObjects();
  }

  void onDoubleTap() {
    print("Main controller: Performing double tap");
    _pipeline.recognizeScene();
  }

  void onLongPress() {
    print("Main controller: Performing long press");
    _pipeline.runFullPerception();
  }
}
