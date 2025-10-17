import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:seawatch/models/avvistamento.dart';

// Servizio per recuperare la lista degli avvistamenti dal server
class AvvistamentiService {

  // Effettua la chiamata HTTP per recuperare gli avvistamenti
  static Future<List<Avvistamento>> fetchAvvistamenti() async {
    const url = 'https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_sighting/sighting_api.php';

    final response = await http.post(
      Uri.parse(url),
      body: {'request': 'tbl_avvistamenti'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Avvistamento.fromJson(data)).toList();
    } else {
      throw Exception('Errore nel recupero degli avvistamenti');
    }
  }
}
