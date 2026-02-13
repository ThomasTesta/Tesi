class Sighting {
  final int id;
  final DateTime? date;
  final int? specimens;
  final String? wind;
  final String? sea;
  final String? notes;
  final double? latitude;
  final double? longitude;

  // Compatibility getters used by UI/map code
  double? get lat => latitude;
  double? get lng => longitude;

  final String? animalName;
  final String? speciesName;

  Sighting({
    required this.id,
    this.date,
    this.specimens,
    this.wind,
    this.sea,
    this.notes,
    this.latitude,
    this.longitude,
    this.animalName,
    this.speciesName,
  });

  factory Sighting.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) => v is String ? DateTime.tryParse(v) : null;

    double? parseDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    String? readName(dynamic x) => (x is Map && x['name'] != null) ? x['name'].toString() : null;

    return Sighting(
      id: (json['id'] as num).toInt(),
      date: parseDate(json['date']),
      specimens: (json['specimens'] is num) ? (json['specimens'] as num).toInt() : null,
      wind: json['wind']?.toString(),
      sea: json['sea']?.toString(),
      notes: json['notes']?.toString(),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      animalName: readName(json['animal']),
      speciesName: readName(json['species']),
    );
  }
}
