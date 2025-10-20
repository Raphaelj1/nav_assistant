import '../modules/scene_recognition/models/scene.dart';
import '../modules/object_perception/models/detected_object.dart';

class PerceptionSummary {
  final Scene scene;
  final List<DetectedObject> objects;

  PerceptionSummary(this.scene, this.objects);
}
