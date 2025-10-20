import 'package:tflite_flutter/tflite_flutter.dart';

class ModelManager {
  static final ModelManager _instance = ModelManager._internal();
  late Interpreter yolo;
  late Interpreter midas;
  // late Interpreter scene;
  bool _initialized = false;

  factory ModelManager() {
    return _instance;
  }

  ModelManager._internal();

  Future<void> init() async {
    if (_initialized) return;

    yolo = await Interpreter.fromAsset('assets/models/yolov8n-seg_float32.tflite');
    midas = await Interpreter.fromAsset('assets/models/midas.tflite');
    // scene = await Interpreter.fromAsset('assets/your_model.tflite');

    _initialized = true;
  }

  void dispose() {
    yolo.close();
    midas.close();
    // scene.close();
    _initialized = false;
  }
}
