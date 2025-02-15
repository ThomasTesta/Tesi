// registration_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
/*
class RegistrationService {
  final String baseUrl = "https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_signup/signup_api.php";
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
    final hmacSha512 = Hmac(sha512, utf8.encode(key)); // Cifra con HMAC-SHA512
    final digest = hmacSha512.convert(utf8.encode(password));
    return digest.toString();
  }

  // Registrazione utente
  Future<void> register(String nome, String cognome, String email, String password) async {
    try {
      // Verifica l'email per ottenere la "key"
      final emailResponse = await postRequest({
        "request": "email",
        "email": email,
      });

      if (emailResponse is Map && emailResponse["state"] == true && emailResponse["Key"] != null) {
        final key = emailResponse["Key"];
        final encryptedPassword = encrypt(password, key); // Cifra la password con la key

        final registerResponse = await postRequest({
          "request": "aggiungiUtente",
          "nome": nome,
          "cognome": cognome,
          "email": email,
          "password": encryptedPassword,
          "key": key,
        });

        if (registerResponse is Map && registerResponse["state"] == false) {
          throw Exception(registerResponse["msg"]);
        }

        print("Registrazione effettuata con successo!");
      } else {
        throw Exception("Errore: Nessuna chiave trovata per l'email fornita.");
      }
    } catch (e) {
      print("Errore durante la registrazione: $e");
      rethrow;
    }
  }
}
*/
// Importa il pacchetto per generare valori casuali
// Importa il pacchetto per generare valori casuali
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';

class RegistrationService {
  final String baseUrl = "https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_signup/signup_api.php";
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
      final response = await request.send().timeout(const Duration(seconds: 10));

      final responseBody = await response.stream.bytesToString();
      print("Corpo della risposta del server: $responseBody");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(responseBody);
        return decoded;
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
    final hmacSha512 = Hmac(sha512, utf8.encode(key)); // Cifra con HMAC-SHA512
    final digest = hmacSha512.convert(utf8.encode(password));
    return digest.toString();
  }

  // Generazione chiave locale
  String generateKey() {
    final random = Random.secure();
    final Uint8List bytes = Uint8List(16);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64Url.encode(bytes);
  }

  // Registrazione utente
  Future<void> register(String nome, String cognome, String email, String password) async {
    try {
      // Genera la chiave localmente
      final key = generateKey();
      final encryptedPassword = encrypt(password, key);

      // Invia richiesta di registrazione
      final registerResponse = await postRequest({
        "request": "aggiungiUtente",
        "nome": nome,
        "cognome": cognome,
        "email": email,
        "password": encryptedPassword,
        "key": key,
      });

      if (registerResponse is Map && registerResponse["state"] == false) {
        throw Exception(registerResponse["msg"]);
      }

      print("Registrazione effettuata con successo!");
    } catch (e) {
      print("Errore durante la registrazione: $e");
      rethrow;
    }
  }
}
