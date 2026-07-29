import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'inbox_screen.dart';
import 'scheduler_screen.dart';
import 'contacts_screen.dart';
import 'settings_screen.dart';

/// Coquille principale avec la barre de navigation inférieure (5 onglets).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  late final List<Widget> _screens = const [
    DashboardScreen(),
    InboxScreen(),
    SchedulerScreen(),
    ContactsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Inbox'),
          NavigationDestination(
              icon: Icon(Icons.send_outlined), selectedIcon: Icon(Icons.send), label: 'Campagnes'),
          NavigationDestination(
              icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Contacts'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Réglages'),
        ],
      ),
    );
  }
}
