import 'dart:typed_data';
import 'package:nav_assistant/modules/depth_estimation/models/depth_map.dart';

class DepthPostprocessor {
  final int modelInputWidth;
  final int modelInputHeight;

  DepthPostprocessor({
    this.modelInputWidth = 256, 
    this.modelInputHeight = 256
  });

  /// Postprocesses MiDaS depth output back to original image resolution.
  DepthMap postprocess(
    Float32List outputTensor, // [1, H, W, 1] flattened
    int originalWidth,
    int originalHeight,
  ) {
    final resizedData = Float32List(originalWidth * originalHeight);

    // Iterate over original image pixels and map them to the depth tensor
    for (int y = 0; y < originalHeight; y++) {
      for (int x = 0; x < originalWidth; x++) {
        // Map coordinates from original image -> depth map coordinates
        final srcX = (x * modelInputWidth / originalWidth).floor();
        final srcY = (y * modelInputHeight / originalHeight).floor();

        final srcIndex = srcY * modelInputWidth + srcX;
        final dstIndex = y * originalWidth + x;

        resizedData[dstIndex] = outputTensor[srcIndex];
      }
    }

    return DepthMap(
      data: resizedData,
      width: originalWidth,
      height: originalHeight,
    );
  }
}
