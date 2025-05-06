import 'package:finch_chat/screens/home.dart';
import 'package:finch_chat/screens/logout.dart';

import 'package:finch_chat/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:finch_chat/screens/settings.dart';
import 'package:finch_chat/view_models/api_config_viewmodel.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApiConfigViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finch Chat',
      theme: finchChatTheme,
      initialRoute: '/',

      routes: {
        // Define the settings route
        '/': (context) => const MyHomePage(title: 'Finch Chat'), // Main layout
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        LogoutScreen.routeName: (context) => const LogoutScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _handleLogout(BuildContext context) {
    // Optional: Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                // Perform actual logout logic here (clear tokens, etc.)

                // Navigate to Login screen and remove all previous routes
                Navigator.pushNamedAndRemoveUntil(
                  context, // Use the main context from build method
                  LogoutScreen.routeName,
                  (Route<dynamic> route) => false, // Remove all routes
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use the primary color from the theme for the AppBar background
        backgroundColor: finchChatTheme.colorScheme.primary,
        iconTheme: IconThemeData(color: finchChatTheme.colorScheme.onPrimary),
        title: Text(
          widget.title,
          style: TextStyle(color: finchChatTheme.colorScheme.onPrimary),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: finchChatTheme.colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png', // Ensure path is correct
                    height: 60,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: finchChatTheme.colorScheme.onPrimary,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Finch Chat',
                    style: TextStyle(
                      color: finchChatTheme.colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              // No selection state needed here
              onTap: () {
                // If already on home ('/'), just close drawer
                // If you implement nested routing later, might need Navigator.popUntil('/')
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              // No selection state needed here
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, SettingsScreen.routeName);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              // No selection state needed here
              onTap: () {
                Navigator.pop(context); // Close the drawer first
                _handleLogout(context); // Call the logout handler
              },
            ),
          ],
        ),
      ),
      // Body now displays the default "Home" content
      body: const HomeScreen(), // Directly use the HomeScreen widget
    );
  }
}
