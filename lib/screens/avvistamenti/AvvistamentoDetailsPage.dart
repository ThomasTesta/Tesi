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
                      "📅 Data dell'avvistamento",
                      widget.avvistamento.data,
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.pets,
                      "🐾 Numero di esemplari",
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
                      "🐾 Animale",
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
