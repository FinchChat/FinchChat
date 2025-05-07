import 'package:flutter/material.dart';
// Assuming you might have a login screen route, e.g.:
// import 'package:finch_chat/screens/login_screen.dart';

class LogoutScreen extends StatefulWidget {
  static const String routeName = '/logout';

  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLogoutConfirmationDialog(context);
    });
  }

  void _performActualLogoutAndNavigate(BuildContext context) {
    // 1. Perform actual logout logic here (clear tokens, user session, etc.)
    // This is where you would call your authentication service to sign out.
    print("Performing actual logout actions...");

    // 2. Navigate to the appropriate screen after logout.
    // For example, navigate to a LoginScreen and remove all previous routes.
    // If you don't have a LoginScreen yet, you might navigate to '/'
    // or another designated "logged out" entry point.

    // Example: Assuming you have a LoginScreen.routeName
    // Navigator.of(context).pushNamedAndRemoveUntil(
    //   LoginScreen.routeName, // Replace with your actual login screen route
    //   (Route<dynamic> route) => false,
    // );

    // For now, let's navigate to the initial route '/' and clear history
    // as a placeholder, assuming '/' can be a public entry or will redirect.
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/', // Or your designated login/home screen for logged-out users
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext mainContext) async {
    // It's important to use the mainContext (from the widget tree) for navigation
    // and the dialogContext for popping the dialog itself.
    return showDialog<void>(
      context: mainContext,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                Navigator.of(mainContext).pop(); // Pop the LogoutScreen itself
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                _performActualLogoutAndNavigate(mainContext);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Processing logout..."), // Or simple text
      ),
    );
  }
}
