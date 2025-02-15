import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:seawatch/models/avvistamento.dart';
/*
class AvvistamentoDetailsPage extends StatefulWidget {
  final Avvistamento avvistamento;

  const AvvistamentoDetailsPage({Key? key, required this.avvistamento})
      : super(key: key);

  @override
  State<AvvistamentoDetailsPage> createState() =>
      _AvvistamentoDetailsPageState();
}

class _AvvistamentoDetailsPageState extends State<AvvistamentoDetailsPage> {
  String? imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

Future<void> _fetchImage() async {
  const apiUrl =
      "https://isi-seawatch.csr.unibo.it/Sito/sito/templates/single_sighting/single_api.php";
  const imageBaseUrl =
      "https://isi-seawatch.csr.unibo.it/Sito/img/avvistamenti/";

  try {
    final response = await http
        .post(
          Uri.parse(apiUrl),
          body: {
            "request": "getImages",
            "id": widget.avvistamento.id.toString(),
          },
        )
        .timeout(Duration(seconds: 10));

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List) {
        print("Decoded Response: $data");

        // Trova la prima immagine valida
        final firstValidImage = data.firstWhere(
          (entry) =>
              entry is Map<String, dynamic> && // Assicurati che sia un Map
              entry['Img'] is String && // Img deve essere una stringa
              entry['Img'].isNotEmpty, // La stringa non deve essere vuota
          orElse: () => null, // Se non ci sono immagini valide
        );

        if (firstValidImage != null) {
          setState(() {
            imageUrl = imageBaseUrl + firstValidImage['Img'];
            print("Image URL: $imageUrl");
            isLoading = false;
          });
        } else {
          print("No valid images found.");
          _handleNoImage();
        }
      } else {
        print("Unexpected data format: $data");
        _handleNoImage();
      }
    } else {
      throw Exception("Errore nel recupero delle immagini");
    }
  } catch (e) {
    print("Errore durante il fetch delle immagini: $e");
    _handleNoImage();
  }
}


  void _handleNoImage() {
    setState(() {
      isLoading = false;
      imageUrl = null; // Puoi impostare un placeholder qui se necessario
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dettagli Avvistamento"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ID: ${widget.avvistamento.id}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "Data: ${widget.avvistamento.data}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "Latitudine: ${widget.avvistamento.latitudine}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "Longitudine: ${widget.avvistamento.longitudine}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "Animale: ${widget.avvistamento.animale}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            // Visualizzazione dinamica dell'immagine o indicatore di caricamento
            isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue.shade800,
                    ),
                  )
                : imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            "Errore nel caricamento dell'immagine",
                            style: TextStyle(color: Colors.red),
                          );
                        },
                      )
                    : Text(
                        "Nessuna immagine disponibile",
                        style: TextStyle(fontSize: 16),
                      ),
          ],
        ),
      ),
    );
  }
}
*/
/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:seawatch/models/avvistamento.dart';

class AvvistamentoDetailsPage extends StatefulWidget {
  final Avvistamento avvistamento;

  const AvvistamentoDetailsPage({Key? key, required this.avvistamento})
      : super(key: key);

  @override
  State<AvvistamentoDetailsPage> createState() =>
      _AvvistamentoDetailsPageState();
}

class _AvvistamentoDetailsPageState extends State<AvvistamentoDetailsPage> {
  String? imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  Future<void> _fetchImage() async {
    const apiUrl =
        "https://isi-seawatch.csr.unibo.it/Sito/sito/templates/single_sighting/single_api.php";
    const imageBaseUrl =
        "https://isi-seawatch.csr.unibo.it/Sito/img/avvistamenti/";

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            body: {
              "request": "getImages",
              "id": widget.avvistamento.id.toString(),
            },
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          final firstValidImage = data.firstWhere(
            (entry) =>
                entry is Map<String, dynamic> &&
                entry['Img'] is String &&
                entry['Img'].isNotEmpty,
            orElse: () => null,
          );

          if (firstValidImage != null) {
            setState(() {
              imageUrl = imageBaseUrl + firstValidImage['Img'];
              isLoading = false;
            });
          } else {
            _handleNoImage();
          }
        } else {
          _handleNoImage();
        }
      } else {
        throw Exception("Errore nel recupero delle immagini");
      }
    } catch (e) {
      _handleNoImage();
    }
  }

  void _handleNoImage() {
    setState(() {
      isLoading = false;
      imageUrl = null;
    });
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  return Scaffold(
    appBar: AppBar(
      title: Text("Dettagli Avvistamento"),
      backgroundColor: theme.colorScheme.primary,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card con immagine
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            child: isLoading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                : imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "Errore nel caricamento dell'immagine",
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Nessuna immagine disponibile",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
          ),
          const SizedBox(height: 16),
          // Dettagli avvistamento
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailTile(
                      Icons.tag, "🆔 Identificativo", widget.avvistamento.id.toString()),
                  _buildDetailTile(
                      Icons.calendar_today, "📅 Data avvistamento", widget.avvistamento.data),
                  _buildDetailTile(
                      Icons.location_on, "📍 Latitudine", widget.avvistamento.latitudine.toString()),
                  _buildDetailTile(
                      Icons.location_on, "📍 Longitudine", widget.avvistamento.longitudine.toString()),
                  _buildDetailTile(Icons.pets, "🐾 Specie osservata", widget.avvistamento.animale),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDetailTile(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.blue.shade800, // Cambia colore o usa il tema
          size: 28, // Dimensione maggiore per evidenziarlo
        ),
        const SizedBox(width: 12), // Spazio tra icona e testo
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}

*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:seawatch/models/avvistamento.dart';

class AvvistamentoDetailsPage extends StatefulWidget {
  final Avvistamento avvistamento;

  const AvvistamentoDetailsPage({Key? key, required this.avvistamento})
      : super(key: key);

  @override
  State<AvvistamentoDetailsPage> createState() =>
      _AvvistamentoDetailsPageState();
}

class _AvvistamentoDetailsPageState extends State<AvvistamentoDetailsPage> {
  String? imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  Future<void> _fetchImage() async {
    const apiUrl =
        "https://isi-seawatch.csr.unibo.it/Sito/sito/templates/single_sighting/single_api.php";
    const imageBaseUrl =
        "https://isi-seawatch.csr.unibo.it/Sito/img/avvistamenti/";

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            body: {
              "request": "getImages",
              "id": widget.avvistamento.id.toString(),
            },
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          final firstValidImage = data.firstWhere(
            (entry) =>
                entry is Map<String, dynamic> &&
                entry['Img'] is String &&
                entry['Img'].isNotEmpty,
            orElse: () => null,
          );

          if (firstValidImage != null) {
            setState(() {
              imageUrl = imageBaseUrl + firstValidImage['Img'];
              isLoading = false;
            });
          } else {
            _handleNoImage();
          }
        } else {
          _handleNoImage();
        }
      } else {
        throw Exception("Errore nel recupero delle immagini");
      }
    } catch (e) {
      _handleNoImage();
    }
  }

  void _handleNoImage() {
    setState(() {
      isLoading = false;
      imageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Dettagli Avvistamento ID: ${widget.avvistamento.id}"),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card con immagine
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              child: isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "Errore nel caricamento dell'immagine",
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            },
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Nessuna immagine disponibile",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
            ),
            const SizedBox(height: 24),

            // Dettagli avvistamento
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailTile(
                      Icons.calendar_today,
                      "📅 Data avvistamento",
                      widget.avvistamento.data,
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.pets,
                      "🐾 Numero esemplari",
                      widget.avvistamento.numeroEsemplari?.toString() ?? 'N/A',
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.air,
                      "💨 Vento",
                      widget.avvistamento.vento ?? 'N/A',
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.water,
                      "🌊 Mare",
                      widget.avvistamento.mare ?? 'N/A',
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.notes,
                      "📝 Note",
                      widget.avvistamento.note ?? 'N/A',
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.gps_fixed,
                      "📍 Latitudine",
                      widget.avvistamento.latitudine.toString(),
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.gps_fixed,
                      "📍 Longitudine",
                      widget.avvistamento.longitudine.toString(),
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.pets,
                      "🐾 Nome animale",
                      widget.avvistamento.animale,
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.science,
                      "🔬 Specie",
                      widget.avvistamento.specie ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.blue.shade800,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
