import 'package:flutter/material.dart';
import 'package:nav_assistant/app/app_routes.dart';
import 'package:nav_assistant/screens/welcome/welcome_controller.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key}); // I removed const
  final _controller = WelcomeController();

  void _completeOnboarding(BuildContext context) async {
    // _controller.completeOnboarding(); // uncomment to skip welcome
    _controller.setOnboarding(false); // uncomment to skip welcome

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.calibration,
    ); // uncomment for full functionality
    // Navigator.pushNamed(context, AppRoutes.calibration); // for testing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SMART NAVIGATION",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Designed for \nindependence. Built with care.",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 40),
              FilledButton(
                onPressed: () => _completeOnboarding(context),
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
                  "Get Started",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
