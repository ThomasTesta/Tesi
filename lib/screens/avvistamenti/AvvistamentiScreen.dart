// Import delle librerie necessarie
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import dei modelli e delle schermate collegate
import 'package:seawatch/models/avvistamento.dart';
import 'package:seawatch/screens/avvistamenti/AvvistamentoDetailsPage.dart';
import 'package:seawatch/screens/avvistamenti/NuovoAvvistamentoScreen.dart';

// Classe principale dello schermo che mostra la lista di tutti gli avvistamenti
class AvvistamentiScreen extends StatefulWidget {
  @override
  _AvvistamentiScreenState createState() => _AvvistamentiScreenState();
}

class _AvvistamentiScreenState extends State<AvvistamentiScreen> {
  late Future<List<Avvistamento>> _futureAvvistamenti; // Futuro che caricherà la lista degli avvistamenti
  List<Avvistamento>? _avvistamenti; // Lista effettiva degli avvistamenti

  @override
  void initState() {
    super.initState();
    _futureAvvistamenti = fetchAvvistamenti(); // Carica gli avvistamenti al lancio
  }

  // Funzione per ordinare la lista degli avvistamenti in base alla data (ascendente o discendente)
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

  // Metodo per costruire l’interfaccia utente
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Ottiene il tema attuale

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Lista Avvistamenti",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        elevation: 4,
        actions: [
          // Bottone "+" nella barra per aggiungere un nuovo avvistamento
          IconButton(
            icon: Icon(Icons.add, size: 28),
            tooltip: "Aggiungi Avvistamento",
            onPressed: () {
              // Naviga alla schermata di creazione nuovo avvistamento
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NuovoAvvistamentoScreen(userEmail: 'thomas.testa@studio.unibo.it'),
                ),
              ).then((newAvvistamento) {
                // Se l’utente ha creato un nuovo avvistamento, aggiungilo alla lista
                if (newAvvistamento != null) {
                  setState(() {
                    _avvistamenti?.add(newAvvistamento);
                    _sortAvvistamentiByDate(ascending: false); // Ordina con i più recenti in alto
                  });
                }
              });
            },
          ),
        ],
      ),

      // Corpo principale della schermata
      body: Container(
        decoration: BoxDecoration(
          // Sfondo sfumato dal blu al bianco
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        // Widget che gestisce lo stato del caricamento asincrono
        child: FutureBuilder<List<Avvistamento>>(
          future: _futureAvvistamenti, // Futuro che restituisce la lista
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Mostra caricamento mentre i dati sono in arrivo
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    const SizedBox(height: 10),
                    const Text(
                      "Caricamento avvistamenti...",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              // Mostra errore se qualcosa va storto durante la richiesta
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      "Errore: ${snapshot.error}",
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _futureAvvistamenti = fetchAvvistamenti(); // Riprova il caricamento
                      }),
                      child: Text("Riprova"),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              // Se ci sono dati validi, salvali se non già presenti
              if (_avvistamenti == null) {
                _avvistamenti = snapshot.data!;
              }

              // Mostra la lista degli avvistamenti in una ListView
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80.0), // Spazio sotto per non coprire contenuto
                itemCount: _avvistamenti!.length,
                itemBuilder: (context, index) {
                  final avvistamento = _avvistamenti![index];

                  // Ogni avvistamento viene rappresentato come una Card
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
                      trailing: Icon(Icons.arrow_forward, color: Colors.blue.shade800),

                      // Quando l’utente clicca sulla card, va ai dettagli
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
              // Nessun dato disponibile
              return Center(child: Text("Nessun avvistamento trovato."));
            }
          },
        ),
      ),
    );
  }

  // Metodo che effettua la chiamata HTTP per recuperare gli avvistamenti dal server
  Future<List<Avvistamento>> fetchAvvistamenti() async {
    const url = 'https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_sighting/sighting_api.php';

    // Invia una POST con il parametro "request"
    final response = await http.post(
      Uri.parse(url),
      body: {'request': 'tbl_avvistamenti'},
    );

    if (response.statusCode == 200) {
      // Se la risposta è OK, decodifica il JSON
      final List<dynamic> jsonResponse = json.decode(response.body);

      // Converte ogni elemento JSON in un oggetto Avvistamento
      return jsonResponse.map((data) => Avvistamento.fromJson(data)).toList();
    } else {
      // In caso di errore lancia un’eccezione
      throw Exception('Errore nel recupero degli avvistamenti');
    }
  }
}
