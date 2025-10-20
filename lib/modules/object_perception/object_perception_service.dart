import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:nav_assistant/core/model_manager.dart';
import 'package:nav_assistant/utils/image_preprocessor.dart';

import './utils/post_processor.dart';

import 'package:nav_assistant/modules/object_perception/models/detected_object.dart';
import './assets/coco_labels.dart';

class ObjectPerceptionService {
  late final Interpreter _interpreter;
  final _postProcessor = YoloPostprocessor();

  ObjectPerceptionService() {
    _interpreter = ModelManager().yolo;
  }

  Future<List<DetectedObject>> detectObjects(img.Image image) async {
    final inputTensor = _preprocess(image);
    final outputTensors = _allocateOutputs();

    print("nTest (object service) Running inference...");
    _interpreter.runForMultipleInputs([inputTensor], outputTensors);
    print("nTest (object service) Running inference complete...");

    final detectedObjects = _postProcessor.postprocess(
      outputTensors,
      image.width,
      image.height,
      cocoLabels,
    );
    return detectedObjects;
  }

  List<List<List<List<double>>>> _preprocess(img.Image image) {
    final resized = ImagePreprocessor.resize(image, 640, 640, letterbox: true, grayBg: true);
    final tensorInput = ImagePreprocessor.normalizeFloat(resized);

    final buffer = List.generate(
      1,
      (_) => List.generate(
        640,
        (y) => List.generate(640, (x) {
          final i = (y * 640 + x) * 3;
          return [
            tensorInput[i], // R
            tensorInput[i + 1], // G
            tensorInput[i + 2], // B
          ];
        }),
      ),
    );

    return buffer;
  }

  Map<int, Object> _allocateOutputs() {
    final detections = List.generate(
      1,
      (_) => List.generate(116, (_) => List.filled(8400, 0.0)),
    );

    final prototypes = List.generate(
      1,
      (_) => List.generate(
        160,
        (_) => List.generate(160, (_) => List.filled(32, 0.0)),
      ),
    );

    return {
      0: detections, // bounding boxes + class scores
      1: prototypes, // segmentation mask prototypes
    };
  }
}