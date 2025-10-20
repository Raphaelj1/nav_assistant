import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

// Assuming flattenNestedList utility
// Float32List flattenNestedList(Object tensor); // Converts nested List to flat Float32List
import '../models/bounding_box.dart';
import '../models/detected_object.dart';
import '../models/segmentation_mask.dart';
import 'flattenNestedList.dart';

class YoloPostprocessor {
  final int modelInputSize;
  final int numClasses;
  final int protoChannels;
  final int protoH;
  final int protoW;
  final double confThreshold;
  final double maskThreshold;
  final double iouThreshold;
  final int maxDetections;

  YoloPostprocessor({
    this.modelInputSize = 640,
    this.numClasses = 80,
    this.protoChannels = 32,
    this.protoH = 160,
    this.protoW = 160,
    this.confThreshold = 0.1,
    this.maskThreshold = 0.2,
    this.iouThreshold = 0.45,
    this.maxDetections = 50,
  });

  List<DetectedObject> postprocess(
    Map<int, Object> outputTensors,
    int origW,
    int origH,
    List<String> labels,
  ) {
    // Compute letterbox parameters
    final double r = math.min(modelInputSize / origW, modelInputSize / origH);
    final int newW = (origW * r).round();
    final int newH = (origH * r).round();
    final int padW = (modelInputSize - newW) ~/ 2;
    final int padH = (modelInputSize - newH) ~/ 2;
    print('Letterbox: r=$r, new_w=$newW, new_h=$newH, pad_w=$padW, pad_h=$padH');

    // Flatten outputs to Float32List
    final Float32List detectionsFlat = flattenNestedList(outputTensors[0]);
    final Float32List prototypesFlat = flattenNestedList(outputTensors[1]);

    // Transpose detections: [1,116,8400] -> [8400,116]
    final int numAnchors = detectionsFlat.length ~/ 116;
    final detections = List.generate(numAnchors, (i) {
      final List<double> row = List.generate(116, (j) => detectionsFlat[j * numAnchors + i]);
      return row;
    });

    // Extract candidates
    final candidates = <Map<String, dynamic>>[];
    for (int i = 0; i < numAnchors; i++) {
      // Scale to model space (0-640)
      final double cx = detections[i][0] * modelInputSize;
      final double cy = detections[i][1] * modelInputSize;
      final double w = detections[i][2] * modelInputSize;
      final double h = detections[i][3] * modelInputSize;
      final classScores = detections[i].sublist(4, 4 + numClasses);
      final maxClassScore = classScores.reduce(math.max);
      final classId = classScores.indexOf(maxClassScore);
      final conf = maxClassScore; // YOLOv8 TFLite fuses objectness

      if (conf > confThreshold) {
        final coeffs = detections[i].sublist(84, 116);
        candidates.add({
          'cx': cx,
          'cy': cy,
          'w': w,
          'h': h,
          'conf': conf,
          'classId': classId,
          'coeffs': coeffs,
        });
        // Debug: Log first 5 candidates
        if (candidates.length <= 5) {
          print('Candidate ${candidates.length}: cx=$cx, cy=$cy, w=$w, h=$h, '
                'conf=$conf, coeffs[0:3]=${coeffs.sublist(0, 3)}');
        }
      }
    }
    print('Number of candidates: ${candidates.length}');

    // Sort by confidence descending
    candidates.sort((a, b) => b['conf'].compareTo(a['conf']));

    // NMS
    final kept = <Map<String, dynamic>>[];
    for (var cand in candidates) {
      if (kept.length >= maxDetections) break;
      bool suppress = false;
      for (var k in kept) {
        final iou = _computeIoU(cand, k);
        if (iou > iouThreshold) {
          suppress = true;
          break;
        }
      }
      if (!suppress) kept.add(cand);
    }
    print('Number of kept detections after NMS: ${kept.length}');

    // Transpose prototypes: [1,160,160,32] -> [32,160*160]
    final protoSize = protoH * protoW;
    final proto = Float32List(protoChannels * protoSize);
    for (int y = 0; y < protoH; y++) {
      for (int x = 0; x < protoW; x++) {
        final p = y * protoW + x;
        for (int c = 0; c < protoChannels; c++) {
          final origIdx = y * (protoW * protoChannels) + x * protoChannels + c;
          proto[c * protoSize + p] = prototypesFlat[origIdx];
        }
      }
    }

    // Build detected objects
    final objects = <DetectedObject>[];
    for (var k in kept) {
      // Scale box to original image
      final x = math.max(0, math.min(origW - 1, ((k['cx'] - k['w'] / 2) - padW) / r));
      final y = math.max(0, math.min(origH - 1, ((k['cy'] - k['h'] / 2) - padH) / r));
      final width = math.max(1, k['w'] / r);
      final height = math.max(1, k['h'] / r);
      final box = BoundingBox(x: x.toDouble(), y: y.toDouble(), w: width.toDouble(), h: height.toDouble());

      // Compute full binary mask
      final fullMask = _computeFullBinaryMask(
        k['coeffs'] as List<double>,
        proto,
        modelInputSize,
        padW,
        padH,
        newW,
        newH,
        origW,
        origH,
      );

      // Crop to box-relative
      final boxRelW = math.max(1, width.round());
      final boxRelH = math.max(1, height.round());
      final boxX = x.round();
      final boxY = y.round();
      final boxRelMask = _cropToBoxRelative(fullMask, origW, origH, boxX, boxY, boxRelW, boxRelH);

      // Verify mask length
      final expectedLength = boxRelW * boxRelH;
      if (boxRelMask.length != expectedLength) {
        print('Warning: Mask length ${boxRelMask.length} does not match $boxRelW x $boxRelH '
              'for ${labels[k['classId']]}');
        continue;
      }

      final mask = SegmentationMask(width: boxRelW, height: boxRelH, data: boxRelMask);

      objects.add(DetectedObject(
        label: labels[k['classId']],
        confidence: k['conf'],
        box: box,
        mask: mask,
      ));

      // Debug: Mask stats
      final onesCount = boxRelMask.where((x) => x == 1).length;
      print('Mask for ${labels[k['classId']]}: sum=$onesCount, expected box size=$boxRelW x $boxRelH');
    }

    return objects;
  }

  double _computeIoU(Map<String, dynamic> a, Map<String, dynamic> b) {
    final ax1 = a['cx'] - a['w'] / 2;
    final ay1 = a['cy'] - a['h'] / 2;
    final ax2 = a['cx'] + a['w'] / 2;
    final ay2 = a['cy'] + a['h'] / 2;

    final bx1 = b['cx'] - b['w'] / 2;
    final by1 = b['cy'] - b['h'] / 2;
    final bx2 = b['cx'] + b['w'] / 2;
    final by2 = b['cy'] + b['h'] / 2;

    final interW = math.max(0, math.min(ax2, bx2) - math.max(ax1, bx1));
    final interH = math.max(0, math.min(ay2, by2) - math.max(ay1, by1));
    final inter = interW * interH;
    final union = a['w'] * a['h'] + b['w'] * b['h'] - inter;
    return union > 0 ? inter / union : 0.0;
  }

  Uint8List _computeFullBinaryMask(
    List<double> coeffs,
    Float32List proto,
    int modelSize,
    int padW,
    int padH,
    int newW,
    int newH,
    int origW,
    int origH,
  ) {
    final protoSize = protoH * protoW;
    final maskFlat = Float32List(protoSize);
    for (int p = 0; p < protoSize; p++) {
      double sum = 0.0;
      for (int c = 0; c < protoChannels; c++) {
        sum += coeffs[c] * proto[c * protoSize + p];
      }
      maskFlat[p] = 1.0 / (1.0 + math.exp(-sum)); // Sigmoid
    }

    // Debug: Sigmoid stats
    final sigmoidMean = maskFlat.reduce((a, b) => a + b) / maskFlat.length;
    final sigmoidMax = maskFlat.reduce(math.max);
    print('Mask sigmoid mean: $sigmoidMean, max: $sigmoidMax');

    // Threshold to binary
    final maskImg = img.Image(width: protoW, height: protoH);
    for (int y = 0; y < protoH; y++) {
      for (int x = 0; x < protoW; x++) {
        final p = y * protoW + x;
        final val = maskFlat[p] > maskThreshold ? 255 : 0;
        maskImg.setPixel(x, y, img.ColorRgb8(val, val, val));
      }
    }

    // Upsample to modelSize
    final upsampled = img.copyResize(maskImg, width: modelSize, height: modelSize,
        interpolation: img.Interpolation.linear);

    // Crop unpad
    final cropped = img.Image(width: newW, height: newH);
    for (int y = 0; y < newH; y++) {
      for (int x = 0; x < newW; x++) {
        final srcX = padW + x;
        final srcY = padH + y;
        if (srcX < modelSize && srcY < modelSize) {
          cropped.setPixel(x, y, upsampled.getPixel(srcX, srcY));
        }
      }
    }

    // Resize to original
    final finalMask = img.copyResize(cropped, width: origW, height: origH,
        interpolation: img.Interpolation.linear);

    // Flatten to binary Uint8List
    final data = Uint8List(origW * origH);
    int idx = 0;
    for (int y = 0; y < origH; y++) {
      for (int x = 0; x < origW; x++) {
        data[idx++] = finalMask.getPixel(x, y).r > 127 ? 1 : 0;
      }
    }
    return data;
  }

  Uint8List _cropToBoxRelative(
    Uint8List fullMask,
    int fullW,
    int fullH,
    int boxX,
    int boxY,
    int boxRelW,
    int boxRelH,
  ) {
    final relMask = Uint8List(boxRelW * boxRelH);
    int idx = 0;
    for (int relY = 0; relY < boxRelH; relY++) {
      for (int relX = 0; relX < boxRelW; relX++) {
        final fullX = math.min(math.max(0, boxX + relX), fullW - 1);
        final fullY = math.min(math.max(0, boxY + relY), fullH - 1);
        relMask[idx++] = fullMask[fullY * fullW + fullX];
      }
    }
    return relMask;
  }
}