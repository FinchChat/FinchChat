import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  // Optional: Define route name if needed for direct navigation
  // static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the content previously shown for Home
    return const Center(
      child: Text(
        'Welcome to the Home Page!',
        style: TextStyle(fontSize: 24), // Using basic style for example
      ),
    );
  }
}
