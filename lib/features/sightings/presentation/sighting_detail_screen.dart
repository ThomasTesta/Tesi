import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/sightings_api.dart';
import '../data/sightings_models.dart';

class SightingDetailScreen extends StatefulWidget {
  final int sightingId;
  const SightingDetailScreen({super.key, required this.sightingId});

  @override
  State<SightingDetailScreen> createState() => _SightingDetailScreenState();
}

class _SightingDetailScreenState extends State<SightingDetailScreen> {
  late Future<Sighting> _future;

  @override
  void initState() {
    super.initState();
    final api = context.read<SightingsApi>();
    _future = api.getSighting(widget.sightingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avvistamento #${widget.sightingId}'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<Sighting>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData && !snap.hasError) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Errore: ${snap.error}'));
          }

          final s = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s.animalName ?? 'Animale'} ${s.speciesName != null ? "(${s.speciesName})" : ""}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text('Data: ${s.date?.toLocal().toString() ?? "n/d"}'),
                const SizedBox(height: 8),
                Text('Posizione: ${s.lat ?? "-"}, ${s.lng ?? "-"}'),
                const SizedBox(height: 8),
                Text('Note: ${s.notes ?? "-"}'),
                const SizedBox(height: 16),

                // Prossimo step: qui attacchiamo immagini + annotazioni
                const Divider(),
                const SizedBox(height: 8),
                const Text('Immagini/Annotazioni: (step successivo)'),
              ],
            ),
          );
        },
      ),
    );
  }
}
