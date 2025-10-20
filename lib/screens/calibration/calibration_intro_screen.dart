import 'package:flutter/material.dart';
import '../../app/app_routes.dart';

class CalibrationIntroScreen extends StatelessWidget {
  const CalibrationIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Calibration', style: TextStyle(fontSize: 18)),
        // centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'Calibrate for Better Accuracy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'To help Guide estimate object distance correctly, you\'ll take three photos of a single object at known distances.',
                // 'You’ll be asked to take 3 photos of an object at 1m, 3m, and 5m. '
                // 'This helps improve distance estimation accuracy.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.calibrationStep);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  textStyle: TextStyle(fontSize: 16),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Start Calibration",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 2),
              TextButton(
                onPressed: () {
                  // Navigator.pushReplacementNamed(context, AppRoutes.main);
                  Navigator.pushNamed(context, AppRoutes.main);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  textStyle: TextStyle(fontSize: 16),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Skip for Now',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
