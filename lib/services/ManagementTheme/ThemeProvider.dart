import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ThemePrefs.dart';

class ThemeProvider with ChangeNotifier {
  late bool _isDark; // Stato corrente del tema
  final ThemePrefs _preferences = ThemePrefs(); // Gestione delle preferenze

  // Getter per verificare se il tema è scuro
  bool get isDark => _isDark;

  // Getter per il tema attuale (ThemeData)
  ThemeData get currentTheme => _isDark ? darkTheme : lightTheme;

  // Costruttore
  ThemeProvider() {
    _isDark = false; // Predefinito
    _loadPreferences(); // Carica il tema dalle preferenze
  }

  // Cambia tema e salva nelle preferenze
  void toggleTheme() {
    _isDark = !_isDark;
    _preferences.setTheme(_isDark); // Salva preferenze
    notifyListeners(); // Aggiorna la UI
  }

  // Carica il tema salvato
  Future<void> _loadPreferences() async {
    _isDark = await _preferences.getTheme();
    notifyListeners(); // Aggiorna la UI dopo il caricamento
  }
}

// Definizione dei temi
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF007BFF),
    secondary: Color(0xFFFFA500),
    onSurface: Colors.black,
  ).copyWith(background: const Color(0xFFF0F8FF)),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color.fromARGB(255, 89, 88, 88),
  bottomAppBarTheme: const BottomAppBarTheme(color: Color.fromARGB(255, 80, 79, 79)),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF00AFFF),
    secondary: Color(0xFFFFA500),
    onSurface: Colors.white,
  ).copyWith(background: const Color.fromARGB(255, 73, 75, 77)),
);
