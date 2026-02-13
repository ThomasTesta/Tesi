import 'package:flutter/material.dart';
import '../data/sightings_api.dart';
import '../data/sightings_models.dart';

class SightingsController extends ChangeNotifier {
  final SightingsApi api;
  SightingsController({required this.api});

  bool loading = false;
  String? error;
  List<Sighting> items = [];

  int _skip = 0;
  final int _take = 50;
  bool _hasMore = true;

  Future<void> refresh() async {
    _skip = 0;
    _hasMore = true;
    items = [];
    await loadMore();
  }

  Future<void> loadMore() async {
    if (loading || !_hasMore) return;
    loading = true;
    error = null;
    notifyListeners();

    try {
      final newItems = await api.getSightings(take: _take, skip: _skip);
      items = [...items, ...newItems];
      _skip += newItems.length;
      if (newItems.length < _take) _hasMore = false;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
