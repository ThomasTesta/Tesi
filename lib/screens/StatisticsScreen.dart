/*
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

@override 
class StatisticsScreen extends StatefulWidget {
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<Map<String, dynamic>>> _sightings;

  @override
  void initState() {
    super.initState();
    _sightings = fetchSightings();
  }

  Future<List<Map<String, dynamic>>> fetchSightings() async {
    final url = Uri.parse(
        'https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_sighting/sighting_api.php');

    final response = await http.post(
      url,
      body: {'request': 'tbl_avvistamenti'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Errore nel caricamento dei dati');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistiche"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.grey[50],
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _sightings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Errore: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Nessun dato disponibile"));
            }

            final sightings = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Panoramica Generale
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: buildOverviewSection(sightings),
                      ),
                    ),
                    // Istogramma
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Istogramma: Numero di Esemplari per Data",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 16),
                            buildHistogram(sightings),
                          ],
                        ),
                      ),
                    ),
                    // Grafico a Torta
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Grafico a Torta: Specie Osservate",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 16),
                            buildPieChartWithLegend(sightings),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

    Widget buildOverviewSection(List<Map<String, dynamic>> sightings) {
    int totalSpecimens = sightings.fold(
      0,
      (total, sighting) {
        final specimens = sighting['Numero_Esemplari'];
        return total + (int.tryParse(specimens?.toString() ?? '0') ?? 0);
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.visibility, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(
              "Numero Totale di Avvistamenti: ${sightings.length}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.assignment_ind, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(
              "Totale Esemplari Visti: $totalSpecimens",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
  Widget buildHistogram(List<Map<String, dynamic>> sightings) {
  Map<String, int> specimensPerDate = {};

  for (var sighting in sightings) {
    String date = sighting['Data']?.split(' ')[0] ?? '';
    int specimens =
        int.tryParse(sighting['Numero_Esemplari']?.toString() ?? '0') ?? 0;

    if (date.isNotEmpty) {
      specimensPerDate[date] = (specimensPerDate[date] ?? 0) + specimens;
    }
  }

  // Ordinare le date
  final sortedDates = specimensPerDate.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  List<BarChartGroupData> barGroups = sortedDates.asMap().entries.map((entry) {
    int index = entry.key;
    int value = entry.value.value;
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: value.toDouble(),
          width: 16,
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(4),
          // Rimuoviamo la parte celeste (background)
          backDrawRodData: BackgroundBarChartRodData(
            show: false, // Disattiviamo il background celeste
            toY: value.toDouble() + 10,
            color: Colors.blue[100],
          ),
        ),
      ],
    );
  }).toList();

  return SizedBox(
    height: 300,
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey[300], strokeWidth: 1),
          // Eliminare i numeri in alto
          drawHorizontalLine: false, // Disattiva le linee orizzontali
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5, // Mostra un'etichetta ogni 5 barre
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value < sortedDates.length) {
                  String date = sortedDates[value.toInt()].key;
                  return Text(
                    date,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    ),
  );
}


Widget buildPieChartWithLegend(List<Map<String, dynamic>> sightings) {
  Map<String, int> speciesCount = {};

  for (var sighting in sightings) {
    String? species = sighting['Specie_Nome'];
    if (species != null && species.isNotEmpty) {
      speciesCount[species] = (speciesCount[species] ?? 0) + 1;
    }
  }

  List<PieChartSectionData> pieSections = speciesCount.entries.map((entry) {
    return PieChartSectionData(
      value: entry.value.toDouble(),
      title: '',
      color: Colors.primaries[
          speciesCount.keys.toList().indexOf(entry.key) % Colors.primaries.length],
      radius: 50,
    );
  }).toList();

return Container(
  padding: const EdgeInsets.only(bottom: 32), // Spazio per evitare il taglio
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Grafico a torta
      Expanded(
        child: SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: pieSections,
              sectionsSpace: 4,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ),
      // Legenda
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: speciesCount.entries.map((entry) {
          return Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: Colors.primaries[
                    speciesCount.keys.toList().indexOf(entry.key) %
                        Colors.primaries.length],
              ),
              const SizedBox(width: 8),
              Text(entry.key),
            ],
          );
        }).toList(),
      ),
    ],
  ),
);

}
}
*/

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<Map<String, dynamic>>> _sightings;

  @override
  void initState() {
    super.initState();
    _sightings = fetchSightings();
  }

  Future<List<Map<String, dynamic>>> fetchSightings() async {
    final url = Uri.parse('https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_sighting/sighting_api.php');
    final response = await http.post(url, body: {'request': 'tbl_avvistamenti'});

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Errore nel caricamento dei dati');
    }
  }

  @override
  Widget build(BuildContext context) {
        final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
          elevation: 4,

      ),
      body: Container(
        color: Colors.blue.shade50,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _sightings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
            } else if (snapshot.hasError) {
              return Center(child: Text('Errore: ${snapshot.error}', style: const TextStyle(color: Colors.black)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Nessun dato disponibile", style: TextStyle(color: Colors.black)));
            }

            final sightings = snapshot.data!.take(15).toList();
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: buildOverviewSection(sightings),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Avvistamenti per mese", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 350, child: buildBarChart(sightings)),
                    const SizedBox(height: 16),
                    Text("Distribuzione degli avvistamenti", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 350, child: buildPieChart(sightings)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildOverviewSection(List<Map<String, dynamic>> sightings) {
    int totalSpecimens = sightings.fold(0, (total, sighting) {
      final specimens = sighting['Numero_Esemplari'];
      return total + (int.tryParse(specimens?.toString() ?? '0') ?? 0);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.visibility, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text("Numero Totale di Avvistamenti: ${sightings.length}", style: const TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.assignment_ind, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text("Totale Esemplari Visti: $totalSpecimens", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget buildBarChart(List<Map<String, dynamic>> sightings) {
    Map<String, int> specimensPerMonth = {};
    for (var sighting in sightings) {
      String rawDate = sighting['Data']?.split(' ')[0] ?? '';
      try {
        DateTime date = DateFormat('dd/MM/yyyy').parse(rawDate);
        String month = DateFormat('MMM yyyy').format(date);
        int specimens = int.tryParse(sighting['Numero_Esemplari']?.toString() ?? '0') ?? 0;
        specimensPerMonth[month] = (specimensPerMonth[month] ?? 0) + specimens;
      } catch (e) {
        continue;
      }
    }

    List<BarChartGroupData> barGroups = specimensPerMonth.entries.map((entry) {
      return BarChartGroupData(
        x: specimensPerMonth.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blueAccent,
            width: 40,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final keys = specimensPerMonth.keys.toList();
                return keys.length > value.toInt()
                    ? Text(keys[value.toInt()], style: TextStyle(fontSize: 12, color: Colors.black))
                    : Container();
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: false),
      ),
    );
  }
}
Widget buildPieChart(List<Map<String, dynamic>> sightings) {
  Map<String, int> speciesCount = {};

  for (var sighting in sightings) {
    String? species = sighting['Specie_Nome'];
    if (species != null && species.isNotEmpty) {
      speciesCount[species] = (speciesCount[species] ?? 0) + 1;
    }
  }

  List<PieChartSectionData> pieSections = speciesCount.entries.map((entry) {
    return PieChartSectionData(
      value: entry.value.toDouble(),
      title: '',
      color: Colors.primaries[
          speciesCount.keys.toList().indexOf(entry.key) % Colors.primaries.length],
      radius: 50,
    );
  }).toList();

  return Column(
    children: [
      SizedBox(
        height: 250, // Aumenta l'altezza per evitare il taglio
        child: Row(
          children: [
            // Grafico a torta
            Expanded(
              flex: 2,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            // Legenda
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: speciesCount.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4), // Spaziatura tra le voci della legenda
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.primaries[
                                speciesCount.keys.toList().indexOf(entry.key) %
                                    Colors.primaries.length],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}


