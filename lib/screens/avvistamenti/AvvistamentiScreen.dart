
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:seawatch/models/avvistamento.dart';
import 'package:seawatch/screens/avvistamenti/AvvistamentoDetailsPage.dart';
import 'package:seawatch/screens/avvistamenti/NuovoAvvistamentoScreen.dart';

class AvvistamentiScreen extends StatefulWidget {
  @override
  _AvvistamentiScreenState createState() => _AvvistamentiScreenState();
}

class _AvvistamentiScreenState extends State<AvvistamentiScreen> {
  late Future<List<Avvistamento>> _futureAvvistamenti;
  List<Avvistamento>? _avvistamenti; // Lista locale

  @override
  void initState() {
    super.initState();
    _futureAvvistamenti = fetchAvvistamenti();
  }

  void _sortAvvistamentiByDate({required bool ascending}) {
    if (_avvistamenti != null) {
      setState(() {
        _avvistamenti!.sort((a, b) {
          final dateA = DateTime.parse(a.data);
          final dateB = DateTime.parse(b.data);
          return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        });
      });
    }
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Lista Avvistamenti"),
      backgroundColor: Colors.blue.shade800,
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            // Aggiunge un nuovo avvistamento
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NuovoAvvistamentoScreen(userEmail: 'thomas.testa@studio.unibo.it'),
              ),
            ).then((newAvvistamento) {
              if (newAvvistamento != null) {
                setState(() {
                  _avvistamenti?.add(newAvvistamento);
                  _sortAvvistamentiByDate(ascending: false); // Riordina se necessario
                });
              }
            });
          },
        ),
      ],
    ),
    body: FutureBuilder<List<Avvistamento>>(
      future: _futureAvvistamenti,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blue),
                const SizedBox(height: 10),
                const Text("Caricamento avvistamenti...",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 10),
                Text("Errore: ${snapshot.error}",
                    style: TextStyle(fontSize: 16, color: Colors.red)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => fetchAvvistamenti(),
                  child: Text("Riprova"),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          // Salva i dati solo al primo caricamento
          if (_avvistamenti == null) {
            _avvistamenti = snapshot.data!;
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80.0),
            itemCount: _avvistamenti!.length,
            itemBuilder: (context, index) {
              final avvistamento = _avvistamenti![index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.pets, color: Colors.blue.shade800),
                  ),
                  title: Text(
                    "Animale: ${avvistamento.animale}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Data: ${avvistamento.data}"),
                  trailing:
                      Icon(Icons.arrow_forward, color: Colors.blue.shade800),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvvistamentoDetailsPage(
                          avvistamento: avvistamento,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        } else {
          return Center(child: Text("Nessun avvistamento trovato."));
        }
      },
    ),
  );
}





Future<List<Avvistamento>> fetchAvvistamenti() async {
  const url = 'https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_sighting/sighting_api.php'; // Modifica con il tuo URL

  final response = await http.post(
    Uri.parse(url),
    body: {'request': 'tbl_avvistamenti'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = json.decode(response.body);

    // Converte i dati JSON in una lista di oggetti Avvistamento
    return jsonResponse.map((data) => Avvistamento.fromJson(data)).toList();
  } else {
    throw Exception('Errore nel recupero degli avvistamenti');
  }
}
}


