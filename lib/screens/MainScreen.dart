import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    ProfileScreen(email: 'thomas.testa@studio.unibo.it',),
    StatisticsScreen(),
    AvvistamentiScreen(),
    const SettingsScreen(), // Impostazioni per il tema
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Recupera il tema corrente
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Schermata principale dinamica
          _screens[_currentIndex],

          // Tab bar circolare posizionata sopra la mappa
          Positioned(
            bottom: 20.0,
            left: 16.0,
            right: 16.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: theme.bottomAppBarTheme.color, // Sfondo dinamico
                borderRadius: BorderRadius.circular(30.0), // Forma circolare
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  width: 1.5,
                ), // Bordo dinamico
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent, // Sfondo trasparente
                elevation: 0, // Nessuna ombra
                selectedItemColor: theme.colorScheme.secondary, // Colore per icona selezionata
                unselectedItemColor: theme.colorScheme.onSurface, // Colore per icona non selezionata
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
        ],
      ),
    );
  }
}
