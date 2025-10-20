import 'package:nav_assistant/modules/depth_estimation/models/depth_map.dart';
import 'package:nav_assistant/modules/object_perception/models/bounding_box.dart';
import 'package:nav_assistant/modules/object_perception/models/segmentation_mask.dart';

// Computes the average depth value of the entire depth map.
// This will be used during calibration to get a representative prediction.
double computeAverageDepth(DepthMap depthMap) {
  double sum = 0.0;
  final data = depthMap.data;

  for (int i = 0; i < data.length; i++) {
    sum += data[i];
  }
  print("nTest (depth utils) average depth ${sum / data.length}");

  return sum / data.length;
}

// Computes a scaling factor given an average predicted depth
// and the corresponding real-world distance in meters (or cm).
// scaling = real_distance / predicted_depth
double computeScalingFactor(double avgDepth, double realDistance) {
  if (avgDepth <= 0) {
    throw ArgumentError('Average depth must be > 0, got $avgDepth');
  }
  return realDistance / avgDepth;
}

// Fits multiple calibration pairs (predicted depths and real distances)
// to compute a single scaling factor via:
//  - averaging all scaling factors (simple)
//  - or linear regression (for more accuracy)
double fitScalingFactors(
  List<double> predicted,
  List<double> real, {
  bool useLinearRegression = true,
}) {
  if (predicted.length != real.length || predicted.isEmpty) {
    throw ArgumentError(
      'Predicted and real lists must be same length and not empty.',
    );
  }

  // return the ratio if there's only one calibration pair
  if (predicted.length < 2) {
    return real[0] / predicted[0];
  }

  if (useLinearRegression) {
    // Linear regression: real = slope * predicted
    final n = predicted.length;
    final meanX = predicted.reduce((a, b) => a + b) / n;
    final meanY = real.reduce((a, b) => a + b) / n;

    double num = 0.0, den = 0.0;
    for (int i = 0; i < n; i++) {
      num += (predicted[i] - meanX) * (real[i] - meanY);
      den += (predicted[i] - meanX) * (predicted[i] - meanX);
    }

    if (den == 0) {
      // fallback
      final factors = <double>[];
      for (int i = 0; i < predicted.length; i++) {
        factors.add(real[i] / predicted[i]);
      }
      return factors.reduce((a, b) => a + b) / factors.length;
    }

    final slope = num / den;
    return slope; // scaling factor
  } else {
    // Simple average of scaling factors
    final factors = <double>[];
    for (int i = 0; i < predicted.length; i++) {
      factors.add(real[i] / predicted[i]);
    }
    return factors.reduce((a, b) => a + b) / factors.length;
  }
}

double computeMaskedAverageDepth(
  DepthMap depthMap,
  SegmentationMask mask,
  BoundingBox box,
) {
  if (mask.width != box.w.round() || mask.height != box.h.round()) {
    throw ArgumentError(
      'Mask size (${mask.width}x${mask.height}) does not match bounding box (${box.w}x${box.h})',
    );
  }

  final data = depthMap.data;
  double sum = 0.0;
  int count = 0;

  final int depthWidth = depthMap.width;
  final int depthHeight = depthMap.height;

  // Clamp box to image bounds
  final int x0 = box.x.round().clamp(0, depthWidth - 1);
  final int y0 = box.y.round().clamp(0, depthHeight - 1);

  for (int my = 0; my < mask.height; my++) {
    final int dy = y0 + my;
    if (dy >= depthHeight) continue;

    for (int mx = 0; mx < mask.width; mx++) {
      final int dx = x0 + mx;
      if (dx >= depthWidth) continue;

      if (mask.at(mx, my) > 0) {
        final int depthIndex = dy * depthWidth + dx;
        sum += data[depthIndex];
        count++;
      }
    }
  }

  if (count == 0) return 0.0; // no valid pixels
  return sum / count;
}
