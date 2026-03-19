import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';
import '../../widgets/floating_nav_bar.dart';
import '../discover/discover_screen.dart';
import '../events/events_screen.dart';
import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  /// Switches to the given tab index from anywhere below the HomeScreen.
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<HomeScreenState>();
    state?.switchToTab(index);
  }

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  /// Programmatically switch to the given tab index.
  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _screens = const [
    DiscoverScreen(),
    SearchScreen(),
    EventsScreen(),
    ExploreScreen(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Tab content with bottom padding so it doesn't hide behind nav bar
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
          // Floating navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingNavBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
            ),
          ),
        ],
      ),
    );
  }
}
