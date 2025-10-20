import 'package:flutter/material.dart';
import '../storage/preferences_service.dart';
import './router.dart';
import './app_routes.dart';
import './theme.dart';

class SmartNavigationApp extends StatefulWidget {
  const SmartNavigationApp({super.key});

  @override
  State<SmartNavigationApp> createState() => _SmartNavigationAppState();
}

class _SmartNavigationAppState extends State<SmartNavigationApp> {
  String? _route;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final prefs = PreferencesService();
    final hasOnboarded = await prefs.getOnboardingStatus();

    setState(() {
      _route = hasOnboarded ? AppRoutes.main : AppRoutes.welcome;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_route == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Navigation Assistant',
      theme: AppTheme.light,
      initialRoute: _route,
      routes: appRoutes,
    );
  }
}
