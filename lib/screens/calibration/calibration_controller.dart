import 'package:image/image.dart' as img;
import 'package:nav_assistant/modules/depth_estimation/models/calibration_sample.dart';

class CalibrationStep {
  final double distance;
  final String instruction;
  img.Image? image; // captured image

  CalibrationStep({
    required this.distance,
    required this.instruction,
    this.image,
  });
}

class CalibrationController {
  int currentStep = 0;

  final List<CalibrationStep> steps = [
    CalibrationStep(
      distance: 1.0,
      instruction: 'Place an object at 1 meter and center it in the camera.',
    ),
    CalibrationStep(
      distance: 3.0,
      instruction: 'Now place the object at 3 meters.',
    ),
    CalibrationStep(
      distance: 5.0,
      instruction: 'Finally, place the object at 5 meters.',
    ),
  ];

  int get totalSteps => steps.length;

  CalibrationStep get current => steps[currentStep];

  void nextStep() {
    if (currentStep < totalSteps - 1) {
      currentStep++;
    }
  }

  bool isLastStep() => currentStep == totalSteps - 1;

  // attach a captured image to the current step
  void attachImage(img.Image image) {
    steps[currentStep].image = image;
  }

  // get the results as a list of {image, distance}
  List<CalibrationSample> getResults() {
    List<CalibrationSample> samples = [];
    
    for (final step in steps) {
      if (step.image != null) {
        samples.add(
          CalibrationSample(image: step.image!, realDistance: step.distance),
        );
      }
    }

    return samples;
  }
}
