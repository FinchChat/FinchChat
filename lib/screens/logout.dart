import 'package:flutter/material.dart';

class LogoutScreen extends StatelessWidget {
  static const String routeName = '/logout';

  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logout'),
        automaticallyImplyLeading: false, // No back button on login screen
      ),
      body: const Center(
        child: Text(
          'You have been logged out.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
