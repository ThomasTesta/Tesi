/*
class Avvistamento {
  final int id;
  final String data;
  final double latitudine;
  final double longitudine;
  final String animale;
  final List<String> immagini; // Nuova proprietà per le immagini

  Avvistamento({
    required this.id,
    required this.data,
    required this.latitudine,
    required this.longitudine,
    required this.animale,
    this.immagini = const [], // Default vuoto se le immagini non sono incluse
  });

  // Factory per creare un oggetto Avvistamento da JSON
  factory Avvistamento.fromJson(Map<String, dynamic> json) {
    return Avvistamento(
      id: json['ID'],
      data: json['Data'],
      latitudine: json['Latid']?.toDouble() ?? 0.0, // Gestione possibile assenza del valore
      longitudine: json['Long']?.toDouble() ?? 0.0,  // Gestione possibile assenza del valore
      animale: json['Anima_Nome'] ?? "Sconosciuto", // Default se non presente
      // Parsing della lista delle immagini
      immagini: json['Immagini'] != null
          ? List<String>.from(json['Immagini'].map((img) => img['Img'] ?? ""))
          : [], // Assicurati che `Immagini` contenga la lista di immagini
    );
  }
}
*/
class Avvistamento {
  final int id;
  final String data;
  final double latitudine;
  final double longitudine;
  final String animale;
  final List<String> immagini; // Lista immagini
  final int numeroEsemplari; // Nuovo campo
  final String vento; // Nuovo campo
  final String mare; // Nuovo campo
  final String note; // Nuovo campo
  final String specie; // Nuovo campo
  final String animaleNome; // Nuovo campo (nome animale)

  Avvistamento({
    required this.id,
    required this.data,
    required this.latitudine,
    required this.longitudine,
    required this.animale,
    this.immagini = const [],
    this.numeroEsemplari = 0, // Default 0
    this.vento = "N/A", // Default "N/A" se non presente
    this.mare = "N/A", // Default "N/A" se non presente
    this.note = "",
    this.specie = "Sconosciuto",
    this.animaleNome = "Sconosciuto",
  });

  // Factory per creare un oggetto Avvistamento da JSON
  factory Avvistamento.fromJson(Map<String, dynamic> json) {
    return Avvistamento(
      id: json['ID'],
      data: json['Data'],
      latitudine: json['Latid']?.toDouble() ?? 0.0,
      longitudine: json['Long']?.toDouble() ?? 0.0,
      animale: json['Anima_Nome'] ?? "Sconosciuto",
      immagini: json['Immagini'] != null
          ? List<String>.from(json['Immagini'].map((img) => img['Img'] ?? ""))
          : [],
      numeroEsemplari: json['Numero_Esemplari'] ?? 0,
      vento: json['Vento'] ?? "N/A",
      mare: json['Mare'] ?? "N/A",
      note: json['Note'] ?? "",
      specie: json['Specie_Nome'] ?? "Sconosciuto",
      animaleNome: json['Anima_Nome'] ?? "Sconosciuto",
    );
  }
}
