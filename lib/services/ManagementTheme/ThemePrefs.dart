import 'package:shared_preferences/shared_preferences.dart';

class ThemePrefs {
  static const String themeKey = "theme";

  // Salva il tema (true per scuro, false per chiaro)
  Future<void> setTheme(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(themeKey, value);
  }

  // Recupera il tema (true per scuro, false per chiaro)
  Future<bool> getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(themeKey) ?? false; // Predefinito chiaro
  }
}
