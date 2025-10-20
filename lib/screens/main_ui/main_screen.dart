import 'package:flutter/material.dart';
import '../../app/app_routes.dart';
import './main_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _mainController = MainController();

  @override
  void initState() {
    super.initState();
    _startlistening();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  // start voice command
  void _startlistening() async {
    await _mainController.init();
    await _mainController.listen();
  }

  // stop voice command
  void _stopListening() async {
    await _mainController.clean();
  }

  void _onSingleTap() async {
    _mainController.onSingleTap();
  }

  void _onDoubleTap() {
    _mainController.onDoubleTap();
  }

  void _onLongPress() {
    _mainController.onLongPress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content area
            Center(
              child: GestureDetector(
                onTap: _onSingleTap,
                onDoubleTap: _onDoubleTap,
                onLongPress: _onLongPress,
                child: Container(
                  width: 350,
                  height: 350,
                  margin: EdgeInsets.only(top: 100),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Container(
                      width: 330,
                      height: 330,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(90),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Settings Button (not in AppBar)
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.settings,
                  size: 32,
                  color: Colors.blueGrey,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
                tooltip: 'Settings',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
