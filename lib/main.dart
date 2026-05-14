import 'package:flutter/material.dart';
import 'package:helloworld/screens/profile_screen.dart';
import 'package:helloworld/screens/task_list_screen.dart';

// runApp() takes a widget and inflates it as the root of the app.
void main() {
  runApp(const MyApp());
}

// StatelessWidget = a widget with no internal state. It looks the same every time.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Task Manager',
      debugShowCheckedModeBanner: false, // Removes the red DEBUG ribbon
      theme: ThemeData(
        // Using teal — NOT the default blue or indigo
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// StatefulWidget = a widget that has state that can change.
// We need this because the selected bottom navigation tab changes.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Tracks which tab is active. 0 = Tasks tab, 1 = Profile tab.
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all screens in memory and shows only the selected one.
      // This means task data is preserved when switching tabs.
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          TaskListScreen(), // shown when _selectedIndex == 0
          ProfileScreen(),  // shown when _selectedIndex == 1
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) {
          // setState() re-runs build() so the screen updates immediately
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rounded),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
