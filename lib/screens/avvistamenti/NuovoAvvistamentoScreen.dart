/*
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class NuovoAvvistamentoScreen extends StatefulWidget {
  final String userEmail;

  NuovoAvvistamentoScreen({required this.userEmail});

  @override
  _NuovoAvvistamentoScreenState createState() => _NuovoAvvistamentoScreenState();
}

class _NuovoAvvistamentoScreenState extends State<NuovoAvvistamentoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller per i campi di input
  final TextEditingController _esemplariController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _mareController = TextEditingController();
  final TextEditingController _ventoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isSaving = false;

  // Per gestione immagini
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  // Variabili per la selezione di animale e specie
  String? _selectedAnimale;
  String? _selectedSpecie;

  List<String> animali = ['Delfino', 'Balena', 'Squalo', 'Tartaruga']; // Esempio
  Map<String, List<String>> specieMap = {
    'Delfino': ['Tursiope', 'Stenella'],
    'Balena': ['Balena Blu', 'Capodoglio'],
    'Squalo': ['Squalo Bianco', 'Squalo Martello'],
    'Tartaruga': ['Caretta', 'Liuto'],
  };

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null && _images.length < 5) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  // Funzione per salvare l'avvistamento
  Future<void> _saveAvvistamento() async {
    if (!_formKey.currentState!.validate()) return;

    // Validazione dei campi obbligatori
    if (_esemplariController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Inserisci il numero di esemplari.")));
      return;
    }

    if (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Inserisci la posizione.")));
      return;
    }

    setState(() => _isSaving = true);

    const url = 'https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_sighting/sighting_api.php';

    final body = {
      'request': 'saveAvvMob',
      'idd': '0',
      'user': widget.userEmail,
      'data': DateTime.now().toIso8601String(),
      'esemplari': _esemplariController.text,
      'latitudine': _latitudeController.text,
      'longitudine': _longitudeController.text,
      'specie': _selectedAnimale ?? '',
      'sottospecie': _selectedSpecie ?? '',
      'mare': _mareController.text,
      'vento': _ventoController.text,
      'note': _noteController.text,
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url))..fields.addAll(body);

      // Invia solo l'avvistamento senza le immagini per ottenere l'ID
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseJson = jsonDecode(responseBody);

        // Se l'ID dell'avvistamento è restituito correttamente
        final avvistamentoId = responseJson['avvistamentoId']; // Supponiamo che l'ID venga restituito così

        // Ora che abbiamo l'ID, associamo le immagini
        if (_images.isNotEmpty && avvistamentoId != null) {
          await _uploadImages(avvistamentoId);
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Avvistamento salvato con successo!")));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore nel salvataggio.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore di rete: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Funzione per caricare le immagini
  Future<void> _uploadImages(String avvistamentoId) async {
    const url = 'https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_sighting/sighting_api.php';

    try {
      for (var image in _images) {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.fields['request'] = 'uploadImage';
        request.fields['avvistamentoId'] = avvistamentoId;
        request.files.add(await http.MultipartFile.fromPath('image', image.path, contentType: MediaType('image', 'jpeg')));
        
        var response = await request.send();

        if (response.statusCode == 200) {
          print("Immagine caricata con successo.");
        } else {
          print("Errore nel caricamento dell'immagine.");
        }
      }
    } catch (e) {
      print("Errore di rete durante il caricamento delle immagini: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nuovo Avvistamento"), backgroundColor: Colors.blue.shade800),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Numero esemplari
              TextFormField(
                controller: _esemplariController,
                decoration: InputDecoration(labelText: "Numero di esemplari"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Inserisci il numero di esemplari.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Posizione GPS (è obbligatoria)
              ElevatedButton(onPressed: _getCurrentLocation, child: Text("Ottieni Posizione GPS")),
              SizedBox(height: 16),
              
              // Animale (opzionale)
              DropdownButtonFormField(
                value: _selectedAnimale,
                items: animali.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedAnimale = val as String?),
                decoration: InputDecoration(labelText: "Animale"),
              ),
              SizedBox(height: 16),
              
              // Specie (opzionale)
              DropdownButtonFormField(
                value: _selectedSpecie,
                items: (_selectedAnimale != null ? specieMap[_selectedAnimale] ?? [] : []).map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => _selectedSpecie = val as String?),
                decoration: InputDecoration(labelText: "Specie"),
              ),
              SizedBox(height: 16),
              
              // Mare (opzionale)
              TextFormField(
                controller: _mareController,
                decoration: InputDecoration(labelText: "Mare"),
              ),
              SizedBox(height: 16),
              
              // Vento (opzionale)
              TextFormField(
                controller: _ventoController,
                decoration: InputDecoration(labelText: "Vento"),
              ),
              SizedBox(height: 16),
              
              // Note (opzionali)
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: "Note"),
              ),
              SizedBox(height: 16),
              
              // Selezione immagine (opzionale)
              ElevatedButton(onPressed: _pickImage, child: Text("Seleziona Immagine")),
              Wrap(children: _images.map((img) => Image.file(img, height: 100)).toList()),
              SizedBox(height: 16),
              
              // Bottone per salvare l'avvistamento
              ElevatedButton(
                onPressed: _isSaving ? null : _saveAvvistamento, 
                child: _isSaving ? CircularProgressIndicator() : Text("Salva Avvistamento")
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:seawatch/screens/avvistamenti/AggiungiImmaginiScreen.dart';

class NuovoAvvistamentoScreen extends StatefulWidget {
  final String userEmail;

  NuovoAvvistamentoScreen({required this.userEmail});

  @override
  _NuovoAvvistamentoScreenState createState() => _NuovoAvvistamentoScreenState();
}

class _NuovoAvvistamentoScreenState extends State<NuovoAvvistamentoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller per i campi di input
  final TextEditingController _esemplariController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _mareController = TextEditingController();
  final TextEditingController _ventoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isSaving = false;

  // Variabili per la selezione di animale e specie
  String? _selectedAnimale;
  String? _selectedSpecie;

  List<String> animali = ['Delfino', 'Balena', 'Squalo', 'Tartaruga']; // Esempio
  Map<String, List<String>> specieMap = {
    'Delfino': ['Tursiope', 'Stenella'],
    'Balena': ['Balena Blu', 'Capodoglio'],
    'Squalo': ['Squalo Bianco', 'Squalo Martello'],
    'Tartaruga': ['Caretta', 'Liuto'],
  };

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
    });
  }

  // Funzione per salvare l'avvistamento senza immagine
  Future<void> _saveAvvistamento() async {
    if (!_formKey.currentState!.validate()) return;

    // Validazione dei campi obbligatori
    if (_esemplariController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Inserisci il numero di esemplari.")));
      return;
    }

    if (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Inserisci la posizione.")));
      return;
    }

    setState(() => _isSaving = true);

    const url = 'https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_sighting/sighting_api.php';

    final body = {
      'request': 'saveAvvMob',
      'idd': '0',
      'user': widget.userEmail,
      'data': DateTime.now().toIso8601String(),
      'esemplari': _esemplariController.text,
      'latitudine': _latitudeController.text,
      'longitudine': _longitudeController.text,
      'specie': _selectedAnimale ?? '',
      'sottospecie': _selectedSpecie ?? '',
      'mare': _mareController.text,
      'vento': _ventoController.text,
      'note': _noteController.text,
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url))..fields.addAll(body);

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseJson = jsonDecode(responseBody);

        final avvistamentoId = responseJson['avvistamentoId']; // Supponiamo che l'ID venga restituito così

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Avvistamento salvato con successo!")));
        
        // Naviga alla schermata per aggiungere le immagini
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AggiungiImmaginiScreen(avvistamentoId: avvistamentoId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore nel salvataggio.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore di rete: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nuovo Avvistamento"), backgroundColor: Colors.blue.shade800),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Numero esemplari
              TextFormField(
                controller: _esemplariController,
                decoration: InputDecoration(labelText: "Numero di esemplari"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Inserisci il numero di esemplari.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Posizione GPS (è obbligatoria)
              ElevatedButton(onPressed: _getCurrentLocation, child: Text("Ottieni Posizione GPS")),
              SizedBox(height: 16),
              
              // Animale (opzionale)
              DropdownButtonFormField(
                value: _selectedAnimale,
                items: animali.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedAnimale = val as String?),
                decoration: InputDecoration(labelText: "Animale"),
              ),
              SizedBox(height: 16),
              
              // Specie (opzionale)
              DropdownButtonFormField(
                value: _selectedSpecie,
                items: (_selectedAnimale != null ? specieMap[_selectedAnimale] ?? [] : []).map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => _selectedSpecie = val as String?),
                decoration: InputDecoration(labelText: "Specie"),
              ),
              SizedBox(height: 16),
              
              // Mare (opzionale)
              TextFormField(
                controller: _mareController,
                decoration: InputDecoration(labelText: "Mare"),
              ),
              SizedBox(height: 16),
              
              // Vento (opzionale)
              TextFormField(
                controller: _ventoController,
                decoration: InputDecoration(labelText: "Vento"),
              ),
              SizedBox(height: 16),
              
              // Note (opzionali)
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: "Note"),
              ),
              SizedBox(height: 16),
              
              // Bottone per salvare l'avvistamento
              ElevatedButton(
                onPressed: _isSaving ? null : _saveAvvistamento, 
                child: _isSaving ? CircularProgressIndicator() : Text("Salva Avvistamento")
              ),
            ],
          ),
        ),
      ),
    );
  }
}
