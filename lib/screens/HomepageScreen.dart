import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class HomepageScreen extends StatefulWidget {
  @override
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  late Future<List<Map<String, dynamic>>> _avvistamenti;

  @override
  void initState() {
    super.initState();
    _avvistamenti = fetchAvvistamenti();
  }

  // Funzione per recuperare gli avvistamenti dalla API
  Future<List<Map<String, dynamic>>> fetchAvvistamenti() async {
    final url = Uri.parse(
        'https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_sighting/sighting_api.php');

    final response = await http.post(
      url,
      body: {'request': 'tbl_avvistamenti'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print("Dati ricevuti: $data");

      final validData = <Map<String, dynamic>>[];

      // Cambia il formato della data
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

      for (var item in data) {
        try {
          // Parsing della data con il formato corretto
          final date = dateFormat.parse(item['Data']);
          final lat = double.parse(item['Latid'].toString());
          final long = double.parse(item['Long'].toString());

          validData.add({
            ...item,
            'Data': date.toIso8601String(), // Converte in formato ISO 8601
            'Latid': lat,
            'Long': long,
          });
        } catch (e) {
          print('Errore nei dati: $item. Dettagli: $e');
        }
      }

      print("Dati validi: $validData");

      validData.sort((a, b) {
        DateTime dateA = DateTime.parse(a['Data']);
        DateTime dateB = DateTime.parse(b['Data']);
        return dateB.compareTo(dateA);
      });

      return validData;
    } else {
      throw Exception('Errore nel caricamento degli avvistamenti');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _avvistamenti,
        builder: (context, snapshot) {
          // Mostra un indicatore di caricamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Mostra un messaggio d'errore
          else if (snapshot.hasError) {
            return Center(
              child: Text('Errore: ${snapshot.error}'),
            );
          }
          // Mostra un messaggio se non ci sono dati
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nessun avvistamento trovato'),
            );
          }

          // Dati caricati con successo
          final avvistamenti = snapshot.data!;
          final recentAvvistamenti = avvistamenti.take(3).toList();

          return Stack(
            children: [
              // Mappa con marker
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(44.144144, 12.253227),
                  initialZoom: 10.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: theme.brightness == Brightness.dark
                        ? 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png'
                        : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: avvistamenti.map((avvistamento) {
                      // Conversione delle coordinate
                      final lat = avvistamento['Latid'] is String
                          ? double.parse(avvistamento['Latid'])
                          : avvistamento['Latid'] as double;

                      final long = avvistamento['Long'] is String
                          ? double.parse(avvistamento['Long'])
                          : avvistamento['Long'] as double;

                      // Marker sulla mappa
                      return Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(lat, long),
                        child: Icon(
                          Icons.location_on,
                          color: theme.colorScheme.secondary, // Colore dinamico
                          size: 40,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              // Barra degli avvistamenti recenti
              Positioned(
                bottom: 90.0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100.0,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentAvvistamenti.length,
                    itemBuilder: (context, index) {
                      final avvistamento = recentAvvistamenti[index];
                      return GestureDetector(
                        onTap: () {
                          // Naviga ai dettagli dell'avvistamento
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AvvistamentoDetailsPage(
                                  avvistamento: avvistamento),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width *
                              0.45, // Ridotto a 80% della larghezza
                          margin: const EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface
                                .withOpacity(0.9), // Sfondo dinamico
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius:8.0,
                                  spreadRadius: 1.0, // Espande l'ombra

                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.tag,
                                        color: theme.colorScheme.secondary,
                                        size: 18),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        //"ID: ${avvistamento['ID']}",
                                        "${avvistamento['Specie_Nome'] ?? 'Specie sconosciuta'}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: theme.colorScheme.secondary,
                                        size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      //"Data: ${avvistamento['Data']}",
                                      "Data: ${DateFormat('MM/dd/yyyy').format(DateTime.parse(avvistamento['Data']))}",

                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.pets,
                                        color: theme.colorScheme.secondary,
                                        size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Numero: ${avvistamento['Numero_Esemplari']}",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: theme.colorScheme.onSurface),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Schermata dei dettagli di un avvistamento

class AvvistamentoDetailsPage extends StatefulWidget {
  final Map<String, dynamic> avvistamento;

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
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "request": "getImages",
          "id": widget.avvistamento['ID'].toString(),
        },
      ).timeout(Duration(seconds: 10));

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
        title: Text('Dettagli Avvistamento ID: ${widget.avvistamento['ID']}'),
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
                side:
                    BorderSide(color: Colors.grey.shade400, width: 1), // Bordo
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
            const SizedBox(height: 24), // Spazio maggiore dopo l'immagine

            // Dettagli avvistamento
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side:
                    BorderSide(color: Colors.grey.shade400, width: 1), // Bordo
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailTile(
                      Icons.calendar_today,
                      "Data avvistamento",
                      widget.avvistamento['Data'] ?? 'N/A',
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.pets,
                      "Numero esemplari",
                      widget.avvistamento['Numero_Esemplari']?.toString() ??
                          'N/A',
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.air,
                      "Vento",
                      widget.avvistamento['Vento'] ?? 'N/A',
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.water,
                      "Mare",
                      widget.avvistamento['Mare'] ?? 'N/A',
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.notes,
                      "Note",
                      widget.avvistamento['Note'] ?? 'N/A',
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.gps_fixed,
                      "Latitudine",
                      widget.avvistamento['Latid']?.toString() ?? 'N/A',
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.gps_fixed,
                      "Longitudine",
                      widget.avvistamento['Long']?.toString() ?? 'N/A',
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.pets,
                      "Nome animale",
                      widget.avvistamento['Anima_Nome'] ?? 'N/A',
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailTile(
                      Icons.science,
                      "Specie",
                      widget.avvistamento['Specie_Nome'] ?? 'N/A',
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
          color: Colors.blue.shade800, // Cambia il colore come preferisci
          size: 28, // Dimensione opzionale per evidenziare meglio l'icona
        ),
        const SizedBox(width: 12), // Spazio tra l'icona e il testo
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
