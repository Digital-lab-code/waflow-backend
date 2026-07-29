import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const WaFlowApp());
}

class WaFlowApp extends StatelessWidget {
  const WaFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaFlow',
      debugShowCheckedModeBanner: false,
      theme: WaFlowTheme.light(),
      home: const OnboardingScreen(),
    );
  }
}
