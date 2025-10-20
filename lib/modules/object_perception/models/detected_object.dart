import 'bounding_box.dart';
import 'segmentation_mask.dart';

class DetectedObject {
  final String label;
  final double confidence;
  final BoundingBox box;
  final SegmentationMask mask;

  DetectedObject({
    required this.label,
    required this.confidence,
    required this.box,
    required this.mask,
  });
}
