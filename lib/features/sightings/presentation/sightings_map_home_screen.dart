import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../state/sightings_controller.dart';
import '../data/sightings_models.dart';

Color colorByAnimal(String? name) {
  final n = (name ?? '').toLowerCase();
  if (n.contains('balen')) return const Color(0xFFA855F7);
  if (n.contains('delfin')) return const Color(0xFF0EA5E9);
  if (n.contains('foca')) return const Color(0xFF64748B);
  if (n.contains('razza')) return const Color(0xFF14B8A6);
  if (n.contains('squal')) return const Color(0xFFEF4444);
  if (n.contains('tartarug')) return const Color(0xFF10B981);
  if (n.contains('tonn')) return const Color(0xFFF59E0B);
  return const Color(0xFF6B7280);
}

class SightingsMapHomeScreen extends StatefulWidget {
  const SightingsMapHomeScreen({super.key});

  @override
  State<SightingsMapHomeScreen> createState() => _SightingsMapHomeScreenState();
}

class _SightingsMapHomeScreenState extends State<SightingsMapHomeScreen> {
  final PopupController _popupController = PopupController();

  Widget _markerPin(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
        ),
        Icon(Icons.location_on, color: color, size: 40),
        const Positioned(
          top: 11,
          child: CircleAvatar(radius: 5, backgroundColor: Colors.white),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers(List<Sighting> items) {
    final valid = items.where((s) => s.latitude != null && s.longitude != null).toList();

    return valid.map((s) {
      final label = (s.speciesName ?? s.animalName ?? 'Sconosciuto');
      return Marker(
        key: ValueKey<int>(s.id), // 👈 fondamentale per ritrovare l’item nel popup
        point: LatLng(s.latitude!, s.longitude!),
        width: 44,
        height: 44,
        child: _markerPin(colorByAnimal(label)),
        rotate: false,
        alignment: Alignment.topCenter,
      );
    }).toList();
  }

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

  Widget _compactPopup(BuildContext context, Sighting s) {
    final theme = Theme.of(context);
    final specie = (s.speciesName ?? s.animalName ?? 'Sconosciuto');
    final color = colorByAnimal(specie);
    final dataStr = s.date != null ? DateFormat('dd/MM/yyyy HH:mm').format(s.date!.toLocal()) : 'N/A';
    final n = s.specimens?.toString() ?? 'N/D';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          boxShadow: const [
            BoxShadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    onTap: () => _popupController.hideAllPopups(),
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
              if (s.latitude != null && s.longitude != null) ...[
                const SizedBox(height: 4),
                _infoRow(
                  context,
                  icon: Icons.gps_fixed,
                  text: '${s.latitude!.toStringAsFixed(4)}, ${s.longitude!.toStringAsFixed(4)}',
                ),
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
                    Navigator.pushNamed(
                      context,
                      AppRoutes.sightingDetail,
                      arguments: s.id,
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

  List<Sighting> _sortByDateDesc(List<Sighting> items) {
    final copy = [...items];
    copy.sort((a, b) {
      final da = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });
    return copy;
  }

  @override
  void initState() {
    super.initState();
    // evita tripli refresh: refresh solo se non hai dati
    Future.microtask(() {
      final ctrl = context.read<SightingsController>();
      if (ctrl.items.isEmpty) ctrl.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = context.watch<SightingsController>();

    if (ctrl.loading && ctrl.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.error != null && ctrl.items.isEmpty) {
      return Center(child: Text('Errore: ${ctrl.error}'));
    }
    if (ctrl.items.isEmpty) {
      return const Center(child: Text('Nessun avvistamento trovato'));
    }

    final sorted = _sortByDateDesc(ctrl.items);
    final recent = sorted.take(3).toList();
    final markers = _buildMarkers(sorted);

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(44.144144, 12.253227),
            initialZoom: 10.0,
            onTap: (_, __) => _popupController.hideAllPopups(),
          ),
          children: [
            TileLayer(
              // Use Carto basemaps (light) — reliable tile server with subdomains
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
            ),
            PopupMarkerLayerWidget(
              options: PopupMarkerLayerOptions(
                popupController: _popupController,
                markers: markers,
                markerTapBehavior: MarkerTapBehavior.togglePopup(),
                popupDisplayOptions: PopupDisplayOptions(
                  builder: (ctx, marker) {
                    final key = marker.key;
                    if (key is ValueKey<int>) {
                      final id = key.value;
                      final s = sorted.firstWhere(
                        (x) => x.id == id,
                        orElse: () => sorted.first,
                      );
                      return _compactPopup(ctx, s);
                    }
                    return const SizedBox.shrink();
                  },
                  snap: PopupSnap.markerTop,
                ),
              ),
            ),
          ],
        ),

        // Barra avvistamenti recenti
        Positioned(
          bottom: 16.0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 110,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemCount: recent.length,
              itemBuilder: (context, index) {
                final s = recent[index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.sightingDetail, arguments: s.id),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.55,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: _RecentItem(s: s),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentItem extends StatelessWidget {
  final Sighting s;
  const _RecentItem({required this.s});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (s.speciesName ?? s.animalName ?? 'Sconosciuto');
    final color = colorByAnimal(title);
    final dateStr = s.date != null ? DateFormat('dd/MM/yyyy HH:mm').format(s.date!.toLocal()) : 'N/A';
    final n = s.specimens?.toString() ?? 'N/D';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: color, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(dateStr, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text('Esemplari: $n', style: theme.textTheme.bodySmall),
        if (s.latitude != null && s.longitude != null) ...[
          const SizedBox(height: 4),
          Text(
            '${s.latitude!.toStringAsFixed(4)}, ${s.longitude!.toStringAsFixed(4)}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
