import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:nav_assistant/core/model_manager.dart';
import 'package:nav_assistant/modules/scene_recognition/models/scene.dart';

class SceneService {
  late final Interpreter _interpreter;

  SceneService() {
    // _interpreter = ModelManager().scene;
  }

  // Future<Scene> classify(Uint8List imageData) async {
  //   final input = preprocess(imageData);
  //   final output = List.filled(NUM_CLASSES, 0).reshape([1, NUM_CLASSES]);

  //   _interpreter.run(input, output);
  // }

  dynamic preprocess(Uint8List imageData) {}

  Scene postprocess(List<List<double>> output) {
    List labels = []; // assuming list is available
    final maxIndex = output[0].indexWhere(
      (v) => v == output[0].reduce((a, b) => a > b ? a : b),
    );
    return Scene(label: labels[maxIndex], confidence: maxIndex.toDouble());
  }
}
