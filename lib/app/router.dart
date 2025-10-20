import 'package:flutter/material.dart';

// screens
import '../screens/welcome/welcome_screen.dart';
import '../screens/calibration/calibration_intro_screen.dart';
import '../screens/calibration/calibration_step_screen.dart';
import '../screens/calibration/calibration_success_screen.dart';
import '../screens/main_ui/main_screen.dart';
import '../screens/settings/settings_screen.dart';

// routes
import './app_routes.dart';

final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.welcome: (context) => WelcomeScreen(), // I removed const
  AppRoutes.calibration: (context) => const CalibrationIntroScreen(),
  AppRoutes.calibrationStep: (context) => const CalibrationStepScreen(),
  AppRoutes.calibrationSuccess: (context) => const CalibrationSuccessScreen(),
  AppRoutes.main: (context) => const MainScreen(),
  AppRoutes.settings: (context) => const SettingsScreen(),
};
