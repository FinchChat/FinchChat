import 'package:finch_chat/utils/pages.dart';
import 'package:finch_chat/utils/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finch Chat',
      theme: finchChatTheme,
      home: const MyHomePage(title: 'Finch Chat'),
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
  String selectedPageName = "Home";

  Widget _buildBody() {
    // Return different widgets based on the selected index
    switch (selectedPageName) {
      case "Home":
        return Center(
          child: Text(
            'Welcome to the Home Page!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
      case "Settings":
        return Center(
          child: Text(
            'Application Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
      case "Logout":
        // Placeholder for Logout - often this triggers navigation or an action
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Logout Selected',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implement actual logout logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout Action Triggered!')),
                  );
                  // Example: Navigate to login screen or clear session
                },
                child: const Text('Confirm Logout'),
              ),
            ],
          ),
        );
      default:
        return Center(
          child: Text(
            'Unknown Page',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use the primary color from the theme for the AppBar background
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(
          getCurrentPageTitle(
            selectedPageName: selectedPageName,
            baseTitle: widget.title,
          ),
        ), // Use the title passed to the widget
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                // Use a theme color for the Drawer header
                color: finchChatTheme.colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center content vertically
                children: [
                  Image.asset(
                    'assets/images/logo.png', // Ensure this path is correct
                    height: 60,
                    errorBuilder: (context, error, stackTrace) {
                      // Placeholder if image fails to load
                      return const Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Finch Chat', // App name in Drawer
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surfaceBright,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(
                'Home',
                style:
                    selectedPageName == "Home"
                        ? TextStyle(color: Colors.white)
                        : TextStyle(color: Colors.black),
              ),
              selected: selectedPageName == "Home",
              selectedTileColor: finchChatTheme.colorScheme.outline,
              onTap: () {
                setState(() {
                  selectedPageName = "Home";
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(
                'Settings',
                style:
                    selectedPageName == "Settings"
                        ? TextStyle(color: Colors.white)
                        : TextStyle(color: Colors.black),
              ),
              selected: selectedPageName == "Settings",
              selectedTileColor: finchChatTheme.colorScheme.outline,
              onTap: () {
                setState(() {
                  selectedPageName = "Settings";
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(
                'Logout',
                style:
                    selectedPageName == "Logout"
                        ? TextStyle(color: Colors.white)
                        : TextStyle(color: Colors.black),
              ),
              selected: selectedPageName == "Logout",
              selectedTileColor: finchChatTheme.colorScheme.outline,
              onTap: () {
                // Select the logout "page" for now
                setState(() {
                  selectedPageName = "Logout";
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      // Use the helper method to build the body dynamically
      body: _buildBody(),
    );
  }
}
