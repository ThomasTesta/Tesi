import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import 'sightings_models.dart';

class SightingsApi {
  final ApiClient client;
  SightingsApi(this.client);

  Future<List<Sighting>> getSightings({
    int take = 50,
    int skip = 0,
    DateTime? fromDate,
    DateTime? toDate,
    int? animalId,
    int? speciesId,
  }) async {
    final res = await client.dio.get(
      Endpoints.sightings,
      queryParameters: {
        'take': take,
        'skip': skip,
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
        if (animalId != null) 'animalId': animalId,
        if (speciesId != null) 'speciesId': speciesId,
      },
    );

    final data = res.data;

    // ✅ Backend: { items: [...], total, take, skip }
    if (data is Map && data['items'] is List) {
      final items = (data['items'] as List)
          .whereType<Map>()
          .map((e) => Sighting.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return items;
    }

    throw Exception('Risposta /sightings non valida: $data');
  }

  Future<Sighting> getSighting(int id) async {
    final res = await client.dio.get('${Endpoints.sightings}/$id');
    final data = res.data;
    if (data is Map) {
      return Sighting.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Risposta /sightings/$id non valida: $data');
  }
}
