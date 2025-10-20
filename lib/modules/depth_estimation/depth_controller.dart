import 'package:image/image.dart' as img;
import 'package:nav_assistant/modules/depth_estimation/depth_service.dart';
import 'package:nav_assistant/modules/depth_estimation/models/depth_map.dart';
import './utils/depth_utils.dart';

import 'package:nav_assistant/storage/calibration_storage.dart';

import 'package:nav_assistant/modules/depth_estimation/models/calibration_sample.dart';
import 'package:nav_assistant/modules/object_perception/models/detected_object.dart';
import 'package:nav_assistant/modules/depth_estimation/models/object_distance.dart';

class DepthController {
  final _service = DepthService();
  final _pref = CalibrationStorage();

  Future<DepthMap> estimateDepth(img.Image frame) async {
    final depthMap = await _service.estimateDepth(frame);
    // print("(depth controller) nTest - depthMap width: ${depthMap.width}");
    return depthMap;
  }

  Future<List<ObjectDistance>> estimateObjectsDistances(
    img.Image frame,
    List<DetectedObject> objects,
  ) async {
    double scalingFactor = await _pref.getScalingFactor();

    final depthMap = await _service.estimateDepth(frame);
    List<ObjectDistance> results = [];

    for (final obj in objects) {
      final avgDepth = computeMaskedAverageDepth(depthMap, obj.mask, obj.box);
      final realDistance = avgDepth * scalingFactor;
      results.add(ObjectDistance(label: obj.label, distance: realDistance));
    }

    return results;
  }

  Future<void> calibrate(List<CalibrationSample> calibrationData) async {
    if (calibrationData.isEmpty) {
      throw ArgumentError("Calibration data cannot be empty.");
    }

    final predicted = <double>[];
    final real = <double>[];

    for (final sample in calibrationData) {
      final depthMap = await _service.estimateDepth(sample.image);
      final avgDepth = computeAverageDepth(depthMap);
      if (avgDepth <= 0) continue;

      predicted.add(avgDepth);
      real.add(sample.realDistance);
    }

    if (predicted.isEmpty) {
      throw Exception("Calibration failed: no valid samples.");
    }

    final finalScalingFactor = fitScalingFactors(predicted, real);

    await _pref.setScalingFactor(finalScalingFactor);
  }
}
