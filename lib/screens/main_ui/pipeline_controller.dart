import 'package:nav_assistant/services/camera_service.dart';
import 'package:nav_assistant/modules/feedback/feedback_controller.dart'; // feedback

import 'package:nav_assistant/modules/object_perception/object_perception_controller.dart'; // objectDetection
import 'package:nav_assistant/modules/depth_estimation/depth_controller.dart'; // depthEstimation
// import 'package:nav_assistant/modules/scene_recognition/scene_controller.dart'; // sceneRecognition


class PipelineController {
  final _feedback = FeedbackController();
  final _camera = CameraService();

  final _objectPerception = ObjectPerceptionController();
  final _depthController = DepthController();
  // final _sceneController = SceneController();

  Future<void> detectObjects() async {
    final frame = await _camera.captureSingleFrame();

    if (frame == null) {
      _feedback.announce("No images captured.");
      return;
    }

    final detectedObjects = await _objectPerception.detectObjects(frame);

    if (detectedObjects.isEmpty) {
      _feedback.announce("No objects detected.");
    } else {
      final objects = await _depthController.estimateObjectsDistances(
        frame,
        detectedObjects,
      );

      await _feedback.announceObjects(objects);
    }
  }

  Future<void> recognizeScene() async {
    // final frame = await _camera.captureSingleFrame();
    // if (frame == null) {
    //   _feedback.announce("Unable to capture scene.");
    //   print("No image captured.");
    //   return;
    // }
    // _feedback.announce("Image captured");

    // final scene = await sceneController.recognizeScene(frame);
    // _feedback.announceScene(scene);

    // _feedback.announceScene(Scene(label: "Kitchen", confidence: 0.9));
    // print("Kitchen Identified");
  }

  Future<void> runFullPerception() async {
    final frame = await _camera.captureSingleFrame();
    if (frame == null) {
      _feedback.announce("Couldn't capture the environment.");
      return;
    }

    // final scene = await sceneController.recognizeScene(frame);
    final detectedObjects = await _objectPerception.detectObjects(frame);

    if (detectedObjects.isEmpty) {
      _feedback.announce("No objects detected.");
    } else {
      final objects = await _depthController.estimateObjectsDistances(
        frame,
        detectedObjects,
      );

      // await _feedback.announceSummary(scene, objects);
      await _feedback.announceObjects(objects);
    }
  }
}
