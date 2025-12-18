import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

// === Colori per animale ===
Color colorByAnimal(String? name) {
  final n = (name ?? '').toLowerCase();
  if (n.contains('balen'))    return const Color(0xFFA855F7); // violet
  if (n.contains('delfin'))   return const Color(0xFF0EA5E9); // sky blue
  if (n.contains('foca'))     return const Color(0xFF64748B); // slate gray
  if (n.contains('razza'))    return const Color(0xFF14B8A6); // teal
  if (n.contains('squal'))    return const Color(0xFFEF4444); // red
  if (n.contains('tartarug')) return const Color(0xFF10B981); // emerald
  if (n.contains('tonn'))     return const Color(0xFFF59E0B); // amber
  return const Color(0xFF6B7280); // default gray
}

class HomepageScreen extends StatefulWidget {
  @override
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  late Future<List<Map<String, dynamic>>> _avvistamenti;
  final PopupController _popupLayerController = PopupController();

  @override
  void initState() {
    super.initState();
    _avvistamenti = fetchAvvistamenti();
  }

  // === API: recupero avvistamenti ===
  Future<List<Map<String, dynamic>>> fetchAvvistamenti() async {
    final url = Uri.parse(
        'https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_sighting/sighting_api.php');

    final response = await http
        .post(url, body: {'request': 'tbl_avvistamenti'})
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final validData = <Map<String, dynamic>>[];
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

      for (var item in data) {
        try {
          final date = dateFormat.parse(item['Data']);
          final lat = double.parse(item['Latid'].toString());
          final long = double.parse(item['Long'].toString());

          validData.add({
            ...item,
            'Data': date.toIso8601String(),
            'Latid': lat,
            'Long': long,
          });
        } catch (_) {
          // scarta item malformati
        }
      }

      validData.sort((a, b) {
        final dateA = DateTime.parse(a['Data']);
        final dateB = DateTime.parse(b['Data']);
        return dateB.compareTo(dateA);
      });

      return validData;
    } else {
      throw Exception('Errore nel caricamento degli avvistamenti');
    }
  }

  // === Marker "puntina" colorato ===
  Widget _markerPin(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow/shadow morbido
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
        ),
        Icon(Icons.location_on, color: color, size: 40),
        // Puntino bianco interno per contrasto
        const Positioned(
          top: 11,
          child: CircleAvatar(radius: 5, backgroundColor: Colors.white),
        ),
      ],
    );
  }

  // === Costruzione markers ===
  List<Marker> _buildMarkers(List<Map<String, dynamic>> avvistamenti) {
    return avvistamenti.map((a) {
      final lat = (a['Latid'] as num).toDouble();
      final lng = (a['Long'] as num).toDouble();
      final specie = (a['Specie_Nome'] ?? a['Anima_Nome'] ?? 'Sconosciuto').toString();

      return Marker(
        point: LatLng(lat, lng),
        width: 44,
        height: 44,
        child: _markerPin(colorByAnimal(specie)),
        rotate: false,
        alignment: Alignment.topCenter, // la puntina "punta" al punto
      );
    }).toList();
  }

  // === Popup compatto stile "recenti" ===
  Widget _compactPopup(BuildContext context, {required Map<String, dynamic> item}) {
    final theme = Theme.of(context);
    final specie = (item['Specie_Nome'] ?? item['Anima_Nome'] ?? 'Sconosciuto').toString();
    final color = colorByAnimal(specie);
    final data = DateTime.tryParse(item['Data'] ?? '');
    final dataStr = data != null ? DateFormat('dd/MM/yyyy HH:mm').format(data) : 'N/A';
    final n = item['Numero_Esemplari']?.toString() ?? 'N/D';
    final lat = (item['Latid'] as num?)?.toDouble();
    final lng = (item['Long'] as num?)?.toDouble();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header compatto
              Row(
                children: [
                  Icon(Icons.location_on, color: color, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      specie,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () => _popupLayerController.hideAllPopups(),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.close, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              _infoRow(context, icon: Icons.calendar_today, text: dataStr),
              const SizedBox(height: 4),
              _infoRow(context, icon: Icons.pets, text: 'Esemplari: $n'),
              if (lat != null && lng != null) ...[
                const SizedBox(height: 4),
                _infoRow(context, icon: Icons.gps_fixed,
                    text: '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}'),
              ],

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Dettagli'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AvvistamentoDetailsPage(avvistamento: item),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Riga informativa compatta
  Widget _infoRow(BuildContext context, {required IconData icon, required String text}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.secondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.75),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _avvistamenti,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessun avvistamento trovato'));
          }

          final avvistamenti = snapshot.data!;
          final recentAvvistamenti = avvistamenti.take(3).toList();
          final markers = _buildMarkers(avvistamenti);

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: const LatLng(44.144144, 12.253227),
                  initialZoom: 10.0,
                  onTap: (_, __) => _popupLayerController.hideAllPopups(),
                ),
                children: [
                  TileLayer(
                    urlTemplate: theme.brightness == Brightness.dark
                        ? 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png'
                        : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  PopupMarkerLayerWidget(
                    options: PopupMarkerLayerOptions(
                      popupController: _popupLayerController,
                      markers: markers,
                      markerTapBehavior: MarkerTapBehavior.togglePopup(),
                      popupDisplayOptions: PopupDisplayOptions(
                        builder: (ctx, marker) {
                          final p = marker.point;
                          final item = avvistamenti.firstWhere(
                            (m) =>
                                (m['Latid'] as num).toDouble() == p.latitude &&
                                (m['Long'] as num).toDouble() == p.longitude,
                            orElse: () => const {},
                          );
                          if (item.isEmpty) return const SizedBox.shrink();
                          return _compactPopup(ctx, item: item);
                        },
                        snap: PopupSnap.markerTop,
                      ),
                    ),
                  ),
                ],
              ),

              // === Barra avvistamenti recenti ===
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AvvistamentoDetailsPage(
                                  avvistamento: avvistamento),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          margin: const EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 8.0,
                                spreadRadius: 1.0,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _RecentItem(avvistamento: avvistamento, theme: theme),
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

// === Recent item (riuso della tua UI) ===
class _RecentItem extends StatelessWidget {
  const _RecentItem({required this.avvistamento, required this.theme});
  final Map<String, dynamic> avvistamento;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(Icons.tag, color: theme.colorScheme.secondary, size: 18),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                "${avvistamento['Specie_Nome'] ?? 'Specie sconosciuta'}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.calendar_today, color: theme.colorScheme.secondary, size: 18),
            const SizedBox(width: 4),
            Text(
              "Data: ${DateFormat('MM/dd/yyyy').format(DateTime.parse(avvistamento['Data']))}",
              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.7)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.pets, color: theme.colorScheme.secondary, size: 18),
            const SizedBox(width: 4),
            Text(
              "Numero: ${avvistamento['Numero_Esemplari']}",
              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
            ),
          ],
        ),
      ],
    );
  }
}

// === Dettagli (schermata) ===
class AvvistamentoDetailsPage extends StatefulWidget {
  final Map<String, dynamic> avvistamento;

  const AvvistamentoDetailsPage({Key? key, required this.avvistamento}) : super(key: key);

  @override
  State<AvvistamentoDetailsPage> createState() => _AvvistamentoDetailsPageState();
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
    const apiUrl = "https://isi-seawatch.csr.unibo.it/Sito/sito/templates/single_sighting/single_api.php";
    const imageBaseUrl = "https://isi-seawatch.csr.unibo.it/Sito/img/avvistamenti/";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {"request": "getImages", "id": widget.avvistamento['ID'].toString()},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          final firstValidImage = data.cast<Map<String, dynamic>?>().firstWhere(
                (entry) => entry != null && entry['Img'] is String && (entry['Img'] as String).isNotEmpty,
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
    } catch (_) {
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade400, width: 1),
            ),
            child: isLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                : imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("Errore nel caricamento dell'immagine", style: TextStyle(color: Colors.red)),
                            );
                          },
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Nessuna immagine disponibile", style: TextStyle(fontSize: 16)),
                      ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade400, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildDetailTile(Icons.calendar_today, "Data avvistamento", widget.avvistamento['Data'] ?? 'N/A'),
                const Divider(height: 20, thickness: 1),
                _buildDetailTile(
                    Icons.pets, "Numero esemplari", widget.avvistamento['Numero_Esemplari']?.toString() ?? 'N/A'),
                const Divider(height: 20, thickness: 1),
                _buildDetailTile(Icons.air, "Vento", widget.avvistamento['Vento'] ?? 'N/A'),
                const Divider(height: 20, thickness: 1),
                _buildDetailTile(Icons.water, "Mare", widget.avvistamento['Mare'] ?? 'N/A'),
                const Divider(height: 20, thickness: 1),
                _buildDetailTile(Icons.notes, "Note", widget.avvistamento['Note'] ?? 'N/A'),
                const Divider(height: 20, thickness: 1),
                _buildDetailTile(Icons.gps_fixed, "Latitudine", widget.avvistamento['Latid']?.toString() ?? 'N/A'),
                const Divider(height: 20, thickness: 1),
                _buildDetailTile(Icons.gps_fixed, "Longitudine", widget.avvistamento['Long']?.toString() ?? 'N/A'),
                const Divider(height: 20, thickness: 1),
                _buildDetailTile(Icons.pets, "Nome animale", widget.avvistamento['Anima_Nome'] ?? 'N/A'),
                const Divider(height: 20, thickness: 1),
                _buildDetailTile(Icons.science, "Specie", widget.avvistamento['Specie_Nome'] ?? 'N/A'),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue.shade800, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          ]),
        ),
      ],
    );
  }
}
