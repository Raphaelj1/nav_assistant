import 'package:flutter/material.dart';
import '../../app/app_routes.dart';
import './settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controller = SettingsController();

  bool? _isHapticEnabled;
  double? _voiceRate;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final hapticEnabled = await _controller.loadHapticSetting();
    final rate = await _controller.loadVoiceRate();

    setState(() {
      _isHapticEnabled = hapticEnabled;
      _voiceRate = rate;
    });
  }

  Future<void> _toggleHaptic(bool value) async {
    setState(() {
      _isHapticEnabled = value;
    });
    await _controller.saveHapticSetting(value);
  }

  Future<void> _updateVoiceRate(double value) async {
    setState(() {
      _voiceRate = value;
    });
    await _controller.saveVoiceRate(value);
  }

  void _goToRecalibration() {
    Navigator.pushNamed(context, AppRoutes.calibration);
  }

  @override
  Widget build(BuildContext context) {
    if (_voiceRate == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontSize: 18)),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Haptic Feedback Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Haptic Feedback', style: TextStyle(fontSize: 16)),
                Switch(
                  value: _isHapticEnabled!,
                  onChanged: _toggleHaptic,
                  activeColor: Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Voice Rate Slider
            const Text('Speech Rate', style: TextStyle(fontSize: 16)),
            Slider(
              value: _voiceRate!,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: _voiceRate!.toStringAsFixed(2),
              onChanged: _updateVoiceRate,
              activeColor: Colors.blue,
              padding: EdgeInsets.fromLTRB(2, 16, 2, 10),
            ),

            const SizedBox(height: 32),

            // Recalibration Button
            FilledButton(
              onPressed: _goToRecalibration,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                minimumSize: const Size.fromHeight(50),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Recalibrate Distance",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
