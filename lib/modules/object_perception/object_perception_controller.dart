import 'package:image/image.dart' as img;
import 'package:nav_assistant/modules/object_perception/models/detected_object.dart';
import 'package:nav_assistant/modules/object_perception/object_perception_service.dart';

class ObjectPerceptionController {
  final _service = ObjectPerceptionService();

  Future<List<DetectedObject>> detectObjects(img.Image frame) async {
    try {
      final objects = await _service.detectObjects(frame);
      return objects;
    } catch (e) {
      return [];
    }
  }
}
