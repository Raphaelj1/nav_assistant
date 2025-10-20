import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:nav_assistant/core/model_manager.dart';
import 'package:nav_assistant/utils/image_preprocessor.dart';

import 'package:nav_assistant/modules/depth_estimation/models/depth_map.dart';

import './utils/post_processor.dart';
import './utils/flattenDepthOutput.dart';

class DepthService {
  late final Interpreter _interpreter;
  final _postProcessor = DepthPostprocessor();

  DepthService() {
    _interpreter = ModelManager().midas;
  }

  Future<DepthMap> estimateDepth(img.Image image) async {
    final inputTensor = _preprocess(image);
    final outputBuffer = _allocateDepthTensor();

    _interpreter.run(inputTensor, outputBuffer);

    final depthMap = _postProcessor.postprocess(
      flattenDepthOutput(outputBuffer),
      image.width,
      image.height,
    );

    return depthMap;
  }

  List<List<List<List<double>>>> _preprocess(img.Image image) {
    final resized = ImagePreprocessor.resize(image, 256, 256);
    final normalized = ImagePreprocessor.normalizeMeanStd(
      resized,
      [0.485, 0.456, 0.406], // mean
      [0.229, 0.224, 0.225], // std
    );

    int index = 0;
    final reshaped = List.generate(
      1,
      (_) => List.generate(
        256,
        (y) => List.generate(
          256,
          (x) => List.generate(3, (c) => normalized[index++]),
        ),
      ),
    );

    return reshaped;
  }

  List<List<List<List<double>>>> _allocateDepthTensor({int H = 256, int W = 256}) {
    // Depth tensor: [1, H, W, 1]
    final depthOutput = List.generate(
      1,
      (_) => List.generate(
        H,
        (_) => List.generate(W, (_) => List.filled(1, 0.0)),
      ),
    );

    return depthOutput;
  }
}
