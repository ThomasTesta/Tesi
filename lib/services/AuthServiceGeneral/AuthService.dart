import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/*

class AuthService {
  final String baseUrl = "https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_login/login_api.php";
  final logger = Logger();

  IOClient createIoClient() {
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return IOClient(httpClient);
  }

  Future<dynamic> postRequest(Map<String, String> body) async {
    final client = createIoClient();
    try {
      final request = http.MultipartRequest("POST", Uri.parse(baseUrl));
      body.forEach((key, value) {
        request.fields[key] = value;
      });
      final response = await request.send().timeout(Duration(seconds: 10));

      final responseBody = await response.stream.bytesToString();
      print("Corpo della risposta del server: $responseBody");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(responseBody);
        return decoded;
      } else if (response.statusCode == 401) {
        throw Exception("Non autorizzato. Verifica email e password.");
      } else {
        throw Exception("Errore del server: ${response.statusCode}");
      }
    } catch (e) {
      logger.e("Errore durante la richiesta HTTP: $e");
      throw Exception("Errore durante la richiesta HTTP: $e");
    }
  }

  // Metodo per cifrare la password con HMAC-SHA512
  String encrypt(String password, String key) {
    print("Cifratura password:"); // Aggiungi questa riga per vedere cosa sta succedendo

    // Mostra la chiave e la password prima della cifratura
    print("Chiave: $key");
    print("Password: $password");

    final hmacSha512 = Hmac(sha512, utf8.encode(key));  // Cambiato sha512 in sha256
    final digest = hmacSha512.convert(utf8.encode(password));

    // Stampa l'hash (cifratura) risultante
    print("Password cifrata (digest): $digest");

    return digest.toString();
  }

Future<void> login(String email, String password) async {
  try {
    email = email.trim().toLowerCase();
    print("Verifica email in corso...");

    // Richiesta per verificare l'email e ottenere la "key"
    final emailResponse = await postRequest({
      "request": "email",
      "email": email,
    });

    if (emailResponse is Map && emailResponse["state"] == true && emailResponse["Key"] != null) {
      final key = emailResponse["Key"];
      print("Chiave ricevuta dal server: $key");

      // Cifra la password con la chiave ottenuta
      final encryptedPassword = encrypt(password, key);

      // Richiesta per effettuare il login
      final loginResponse = await postRequest({
        "request": "pwd",
        "email": email,
        "password": encryptedPassword,
      });

      if (loginResponse is Map && loginResponse["state"] == false) {
        throw Exception(loginResponse["msg"]);
      }

      // Salva la sessione
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true); // Salva lo stato
      await prefs.setString('userEmail', email); // Opzionale: salva l'email

      print("Login effettuato con successo!");
    } else {
      throw Exception("Errore: Nessuna chiave trovata per l'email fornita.");
    }
  } catch (e) {
    print("Errore durante il login: $e");
    rethrow;
  }
}

Future<bool> checkSession() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isAuthenticated') ?? false;
}

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Rimuove tutte le preferenze salvate
  print("Utente disconnesso");
}

// Metodo di validazione per password
bool _isValidPassword(String password) {
  final passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  return passwordRegex.hasMatch(password);
}


Future<void> changePassword(BuildContext context, String email, String oldPassword, String newPassword) async {
  try {
    // Passaggio 1: Ottenere la chiave
    final keyResponse = await postRequest({
      "request": "getKeyMob",
      "user": email,
    });

    final keyJson = jsonDecode(keyResponse);
    if (keyJson["key"] == null) {
      throw Exception("Chiave non trovata.");
    }

    final key = keyJson["key"];

    // Hash delle password
    final hashedOldPassword = calculateHmacSha512(oldPassword, key);
    final hashedNewPassword = calculateHmacSha512(newPassword, key);

    // Passaggio 2: Cambiare la password
    final changePasswordResponse = await postRequest({
      "request": "changePwdMob",
      "user": email,
      "old": hashedOldPassword,
      "new": hashedNewPassword,
    });

    final changeJson = jsonDecode(changePasswordResponse);
    if (changeJson["stato"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(changeJson["msg"] ?? "Password cambiata con successo.")),
      );
    } else {
      throw Exception(changeJson["msg"] ?? "Errore durante il cambio password.");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Errore: $e')),
    );
  }
}

String calculateHmacSha512(String message, String key) {
  var keyBytes = utf8.encode(key);
  var messageBytes = utf8.encode(message);

  var hmac = Hmac(sha512, keyBytes); // Usa SHA-512
  var digest = hmac.convert(messageBytes);

  return digest.toString();
}



}
*/

/*
Future<void> changePassword(BuildContext context, String oldPassword, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = prefs.getString('userEmail');

      if (user == null) {
        throw Exception('Utente non autenticato. Effettua il login.');
      }

      // Step 1: Ottenere la chiave dal server
      final keyResponse = await postRequest({
        "request": "getKeyMob",
        "user": user,
      });

      if (keyResponse["key"] == null) {
        throw Exception("Errore: impossibile ottenere la chiave per cifrare la password.");
      }

      final key = keyResponse["key"];

      // Step 2: Cifrare vecchia e nuova password
      final hashedOldPassword = encrypt(oldPassword, key);
      final hashedNewPassword = encrypt(newPassword, key);

      // Step 3: Inviare la richiesta di cambio password
      final changePasswordResponse = await postRequest({
        'request': 'changePwdMob',
        'old': hashedOldPassword,
        'new': hashedNewPassword,
        'user': user,
      });

      if (changePasswordResponse["stato"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(changePasswordResponse['msg'] ?? 'Password cambiata con successo.')),
        );

        // Logout automatico
        await logout();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(), // Schermata di login
        ));
      } else {
        throw Exception(changePasswordResponse['msg'] ?? 'Errore durante il cambio password.');
      }
    } catch (e) {
      logger.e("Errore durante il cambio password: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    }
  }
}
*/

// auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AuthService {
  final String baseUrl = "https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_login/login_api.php";
  final logger = Logger();

  IOClient createIoClient() {
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return IOClient(httpClient);
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await http.get(Uri.parse("https://www.google.com")).timeout(Duration(seconds: 3));
      return result.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<dynamic> postRequest(Map<String, String> body) async {
    final client = createIoClient();
    try {
      final request = http.MultipartRequest("POST", Uri.parse(baseUrl));
      body.forEach((key, value) {
        request.fields[key] = value;
      });
      final response = await request.send().timeout(const Duration(seconds: 10));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(responseBody);
      } else if (response.statusCode == 401) {
        throw Exception("Non autorizzato. Verifica email e password.");
      } else {
        throw Exception("Errore del server: ${response.statusCode}");
      }
    } catch (e) {
      logger.e("Errore HTTP: $e");
      rethrow;
    }
  }

  String encrypt(String password, String key) {
    final hmacSha512 = Hmac(sha512, utf8.encode(key));
    final digest = hmacSha512.convert(utf8.encode(password));
    return digest.toString();
  }

  Future<void> login(String email, String password) async {
    email = email.trim().toLowerCase();

    final emailResponse = await postRequest({
      "request": "email",
      "email": email,
    });

    if (emailResponse is Map && emailResponse["state"] == true && emailResponse["Key"] != null) {
      final key = emailResponse["Key"];
      final encryptedPassword = encrypt(password, key);

      final loginResponse = await postRequest({
        "request": "pwd",
        "email": email,
        "password": encryptedPassword,
      });

      if (loginResponse is Map && loginResponse["state"] == false) {
        throw Exception(loginResponse["msg"]);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('encryptedPassword', encryptedPassword);
      await prefs.setString('encryptionKey', key);
    } else {
      throw Exception("Errore: Nessuna chiave trovata per l'email.");
    }
  }

  Future<bool> loginOffline(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('userEmail');
    final savedEncryptedPassword = prefs.getString('encryptedPassword');
    final savedKey = prefs.getString('encryptionKey');

    if (savedEmail == null || savedEncryptedPassword == null || savedKey == null) {
      return false;
    }

    final encryptedInputPassword = encrypt(password, savedKey);
    return email == savedEmail && encryptedInputPassword == savedEncryptedPassword;
  }

  Future<void> attemptLogin(String email, String password) async {
    final connected = await hasInternetConnection();

    if (connected) {
      try {
        await login(email, password);
        print("✅ Login online riuscito.");
      } catch (e) {
        print("❌ Login online fallito: $e");
        throw Exception("Login online fallito: $e");
      }
    } else {
      final offlineOk = await loginOffline(email, password);
      if (offlineOk) {
        print("✅ Login offline riuscito.");
      } else {
        print("❌ Login offline fallito.");
        throw Exception("Login offline fallito: nessuna connessione e credenziali non valide.");
      }
    }
  }

  Future<bool> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAuthenticated') ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("👋 Utente disconnesso.");
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> changePassword(BuildContext context, String email, String oldPassword, String newPassword) async {
    try {
      final keyResponse = await postRequest({
        "request": "getKeyMob",
        "user": email,
      });

      final key = keyResponse["key"];
      if (key == null) throw Exception("Chiave non trovata.");

      final hashedOldPassword = encrypt(oldPassword, key);
      final hashedNewPassword = encrypt(newPassword, key);

      final changePasswordResponse = await postRequest({
        "request": "changePwdMob",
        "user": email,
        "old": hashedOldPassword,
        "new": hashedNewPassword,
      });

      if (changePasswordResponse["stato"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(changePasswordResponse["msg"] ?? "Password cambiata con successo.")),
        );
      } else {
        throw Exception(changePasswordResponse["msg"] ?? "Errore cambio password.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    }
  }
}
