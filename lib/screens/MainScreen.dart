import 'dart:io'; // Per Platform.isIOS
import 'package:flutter/material.dart';
import 'package:seawatch/screens/HomepageScreen.dart';
import 'package:seawatch/screens/ProfileScreen.dart';
import 'package:seawatch/screens/StatisticsScreen.dart';
import 'package:seawatch/screens/avvistamenti/AvvistamentiScreen.dart';
import 'package:seawatch/screens/settingScreens/SettingsScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomepageScreen(),
    ProfileScreen(
      email: 'thomas.testa@studio.unibo.it',
    ),
    StatisticsScreen(),
    AvvistamentiScreen(),
    const SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea( // Protegge da notch e bordi su iOS
      child: Scaffold(
        body: Stack(
          children: [
            _screens[_currentIndex],
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: Platform.isIOS ? 20.0 : 16.0, // più spazio su iOS
                  left: 16.0,
                  right: 16.0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: theme.bottomAppBarTheme.color,
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedItemColor: theme.colorScheme.secondary,
                    unselectedItemColor: theme.colorScheme.onSurface,
                    currentIndex: _currentIndex,
                    onTap: _onTabTapped,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: 'Profile',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.bar_chart),
                        label: 'Statistics',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.list),
                        label: 'Avvistamenti',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings),
                        label: 'Settings',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
