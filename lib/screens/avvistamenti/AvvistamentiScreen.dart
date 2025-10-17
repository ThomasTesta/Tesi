import 'package:flutter/material.dart';
import 'package:seawatch/models/avvistamento.dart';
import 'package:seawatch/screens/avvistamenti/AvvistamentoDetailsPage.dart';
import 'package:seawatch/screens/avvistamenti/NuovoAvvistamentoScreen.dart';
import 'package:seawatch/services/AvvistamentiService.dart';

/// Schermata che mostra la lista degli avvistamenti
class AvvistamentiScreen extends StatefulWidget {
  @override
  _AvvistamentiScreenState createState() => _AvvistamentiScreenState();
}

class _AvvistamentiScreenState extends State<AvvistamentiScreen> {
  late Future<List<Avvistamento>> _futureAvvistamenti;
  List<Avvistamento>? _avvistamenti;

  @override
  void initState() {
    super.initState();
    _futureAvvistamenti = AvvistamentiService.fetchAvvistamenti(); // Uso del servizio esterno
  }

  /// Ordina la lista per data (ascendente o discendente)
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Lista Avvistamenti",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 28),
            tooltip: "Aggiungi Avvistamento",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NuovoAvvistamentoScreen(userEmail: 'thomas.testa@studio.unibo.it'),
                ),
              ).then((newAvvistamento) {
                if (newAvvistamento != null) {
                  setState(() {
                    _avvistamenti?.add(newAvvistamento);
                    _sortAvvistamentiByDate(ascending: false);
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Avvistamento>>(
          future: _futureAvvistamenti,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    const SizedBox(height: 10),
                    const Text("Caricamento avvistamenti...", style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                    Text("Errore: ${snapshot.error}", style: TextStyle(fontSize: 16, color: Colors.red)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _futureAvvistamenti = AvvistamentiService.fetchAvvistamenti();
                      }),
                      child: Text("Riprova"),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
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
                      trailing: Icon(Icons.arrow_forward, color: Colors.blue.shade800),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AvvistamentoDetailsPage(avvistamento: avvistamento),
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
      ),
    );
  }
}
