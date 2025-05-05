import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  // Route name for navigation
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // Automatically adds a back button
      ),
      body: const Center(
        child: Text(
          'This is the dedicated Settings Screen!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
