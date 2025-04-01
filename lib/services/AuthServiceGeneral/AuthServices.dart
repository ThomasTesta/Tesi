import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  final String baseUrl = "https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_settings/settings_api.php";

  // Metodo per ottenere la chiave
  Future<String?> getKey(String user) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          "request": "getKeyMob",
          "user": user,
        },
      );

      //print("Invio getKeyMob: ${response.request?.body}");
      print("Risposta getKeyMob: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["key"];
      } else {
        print("Errore nella risposta del server: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Errore durante getKey: $e");
      return null;
    }
  }

  // Metodo per cambiare la password
  Future<Map<String, dynamic>> changePassword(String user, String oldPassword, String newPassword) async {
    try {
      final key = await getKey(user);
      if (key == null) {
        return {
          "success": false,
          "message": "Errore durante il recupero della chiave di cifratura.",
        };
      }

String calculateHmacSha512(String input, String key) {
  final hmac = Hmac(sha512, utf8.encode(key)); // Usa la chiave direttamente
  final digest = hmac.convert(utf8.encode(input));
  
  print("HMAC di '$input' con chiave diretta: $digest"); // Debug
  return digest.toString();
}






      final oldHashed = calculateHmacSha512(oldPassword, key);
      final newHashed = calculateHmacSha512(newPassword, key);

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          "request": "changePwdMob",
          "user": user,
          "old": oldHashed,
          "new": newHashed,
        },
      );

      //print("Invio changePwdMob: ${response.request?.body}");
      print("Risposta changePwdMob: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": data["stato"] ?? false,
          "message": data["msg"] ?? "Errore sconosciuto.",
        };
      } else {
        return {
          "success": false,
          "message": "Errore nella risposta del server: ${response.statusCode}",
        };
      }
    } catch (e) {
      print("Errore durante changePassword: $e");
      return {
        "success": false,
        "message": "Errore durante la richiesta al server.",
      };
    }
  }
}
