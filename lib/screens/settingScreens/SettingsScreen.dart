import 'package:flutter/material.dart';
import 'package:seawatch/screens/settingScreens/ProfileChangeScreen.dart';
import 'package:seawatch/screens/settingScreens/SecurityScreen.dart';
import 'package:seawatch/screens/settingScreens/ThemeScreen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSettingsTile(
              context,
              icon: Icons.person,
              title: 'Profilo',
              screen: ProfileChangeScreen(),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.lock,
              title: 'Sicurezza',
              screen: SecurityScreen(),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.brightness_6,
              title: 'Tema',
              screen: const ThemeScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required Widget screen}) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(icon, color: theme.colorScheme.primary, size: 28),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios, color: theme.colorScheme.onSurface, size: 20),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        },
      ),
    );
  }   //commento diu opriva
}
