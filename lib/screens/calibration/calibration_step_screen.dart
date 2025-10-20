import 'package:flutter/material.dart';
import 'calibration_controller.dart';
import 'package:nav_assistant/app/app_routes.dart';
import 'package:nav_assistant/services/camera_service.dart';
import 'package:nav_assistant/modules/depth_estimation/depth_controller.dart';

class CalibrationStepScreen extends StatefulWidget {
  const CalibrationStepScreen({super.key});

  @override
  State<CalibrationStepScreen> createState() => _CalibrationStepScreenState();
}

class _CalibrationStepScreenState extends State<CalibrationStepScreen> {
  final _calibrationController = CalibrationController();
  final _depthController = DepthController();
  final _cameraService = CameraService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onCapturePressed() async {
    final image = await _cameraService.captureFromPreview();
    if (image != null) {
      _calibrationController.attachImage(image);
    }
    if (_calibrationController.isLastStep()) {
      final results = _calibrationController.getResults();
      print("Calibration step screen: There are ${results.length} results."); // debugging
      await _depthController.calibrate(results);
      Navigator.pushReplacementNamed(context, AppRoutes.calibrationSuccess);
    } else {
      setState(() {
        _calibrationController.nextStep();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _calibrationController.current;
    final totalSteps = _calibrationController.totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calibration', style: TextStyle(fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    'Capture Photo at ${step.distance}m',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    color: Colors.grey[300],
                    width: 350,
                    height: 525,
                    child: _cameraService.isInitialized
                        ? _cameraService.buildPreview()
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  // const SizedBox(height: 20),
                  Text(
                    step.instruction,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 5,
                    children: [
                      for (int i = 0; i < totalSteps; i++)
                        Container(
                          width: 20,
                          height: 5,
                          decoration: BoxDecoration(
                            color: i == _calibrationController.currentStep
                                ? Colors.lightBlue
                                : Colors.blueGrey[100],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 32),
                  FilledButton(
                    onPressed: _onCapturePressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      textStyle: TextStyle(fontSize: 16),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _calibrationController.isLastStep()
                          ? 'Finish Calibration'
                          : 'Capture',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
