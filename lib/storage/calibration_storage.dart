import 'package:shared_preferences/shared_preferences.dart';

class CalibrationStorage {
  static const _scalingFactorKey = 'scalingFactor';

  Future<double> getScalingFactor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_scalingFactorKey) ?? 0.5;
  }

  Future<void> setScalingFactor(double scalingFactor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_scalingFactorKey, scalingFactor);
  }
}
