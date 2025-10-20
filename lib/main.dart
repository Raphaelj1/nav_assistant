import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/model_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ModelManager().init();
  runApp(const SmartNavigationApp());
}
