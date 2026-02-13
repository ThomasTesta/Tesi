import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../state/sightings_controller.dart';
import '../data/sightings_models.dart';

class SightingsListScreen extends StatefulWidget {
  const SightingsListScreen({super.key});

  @override
  State<SightingsListScreen> createState() => _SightingsListScreenState();
}

class _SightingsListScreenState extends State<SightingsListScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SightingsController>().refresh());

    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 250) {
        context.read<SightingsController>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SightingsController>();

    if (ctrl.loading && ctrl.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ctrl.error != null && ctrl.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Errore: ${ctrl.error}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ctrl.refresh(),
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: ctrl.refresh,
      child: ListView.separated(
        controller: _scroll,
        itemCount: ctrl.items.length + (ctrl.loading ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          if (i >= ctrl.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final s = ctrl.items[i];
          return _SightingTile(
            sighting: s,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.sightingDetail,
              arguments: s.id,
            ),
          );
        },
      ),
    );
  }
}

class _SightingTile extends StatelessWidget {
  final Sighting sighting;
  final VoidCallback onTap;

  const _SightingTile({required this.sighting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = sighting.date?.toLocal().toString() ?? 'Data n/d';
    final title = [
      sighting.animalName ?? 'Animale n/d',
      if (sighting.speciesName != null) '(${sighting.speciesName})',
    ].join(' ');

    final subtitle = [
      date,
      if (sighting.lat != null && sighting.lng != null)
        '📍 ${sighting.lat!.toStringAsFixed(4)}, ${sighting.lng!.toStringAsFixed(4)}',
      if (sighting.notes != null && sighting.notes!.isNotEmpty) '📝 ${sighting.notes}',
    ].join('\n');

    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
