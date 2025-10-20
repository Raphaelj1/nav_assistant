import 'package:nav_assistant/modules/scene_recognition/models/scene.dart';
import 'package:nav_assistant/modules/depth_estimation/models/object_distance.dart';

import './tts_service.dart';
import './haptic_service.dart';

class FeedbackController {
  final _tts = TtsService();

  Future<void> announce(String info) async {
    await _tts.speak(info);
  }

  Future<void> announceObjects(List<ObjectDistance> objects) async {
    String feedback;

    if (objects.isEmpty) {
      feedback = "No objects detected nearby.";
    } else if (objects.length == 1) {
      final object = objects.first;
      feedback =
          "There is a ${object.label} about ${object.distance.toStringAsFixed(1)} meters ahead.";
    } else {
      final descriptions = objects
          .map((o) => "${o.label} at ${o.distance.toStringAsFixed(1)} meters")
          .toList();

      feedback =
          "I see ${descriptions.sublist(0, descriptions.length - 1).join(", ")}"
          " and ${descriptions.last}.";
    }

    await HapticService.vibrate();
    await _tts.speak(feedback);
  }

  Future<void> announceScene(Scene scene) async {
    final description = "This place looks like ${scene.label}";
    await HapticService.vibrate();
    await _tts.speak(description);
  }

  Future<void> announceSummary(
    Scene? scene,
    List<ObjectDistance> objects,
  ) async {
    String feedback;

    if (scene != null) {
      feedback = "You are in ${scene.label}.";
    } else {
      feedback = "I cannot determine the scene";
    }

    // Objects description
    if (objects.isEmpty) {
      feedback += " No objects detected nearby.";
    } else if (objects.length == 1) {
      final object = objects.first;
      feedback +=
          "There is a ${object.label} about ${object.distance.toStringAsFixed(1)} meters ahead.";
    } else {
      final objectDescriptions = objects.map((obj) {
        return "${obj.label} at ${obj.distance.toStringAsFixed(1)} meters";
      }).toList();

      // Natural phrasing: comma-separated, with "and" before the last one
      feedback +=
          " I can see ${objectDescriptions.sublist(0, objectDescriptions.length - 1).join(", ")}"
          " and ${objectDescriptions.last}.";
    }

    await HapticService.vibrate();
    await _tts.speak(feedback);
  }

  Future<void> dispose() async {
    await _tts.dispose();
  }
}
