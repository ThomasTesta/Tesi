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

/*
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
*/
/*
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

  final TextEditingController _esemplariController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _mareController = TextEditingController();
  final TextEditingController _ventoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isSaving = false;
  String? _selectedAnimale;
  String? _selectedSpecie;

  List<String> animali = ['Delfino', 'Balena', 'Squalo', 'Tartaruga'];
  Map<String, List<String>> specieMap = {
    'Delfino': ['Tursiope', 'Stenella'],
    'Balena': ['Balena Blu', 'Capodoglio'],
    'Squalo': ['Squalo Bianco', 'Squalo Martello'],
    'Tartaruga': ['Caretta', 'Liuto'],
  };

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
    });
  }

  Future<void> _saveAvvistamento() async {
    if (!_formKey.currentState!.validate()) return;

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
        final avvistamentoId = responseJson['avvistamentoId'];

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Avvistamento salvato con successo!")));

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AggiungiImmaginiScreen(avvistamentoId: avvistamentoId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Errore nel salvataggio.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore di rete: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboardType}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(icon, color: Colors.blue),
            border: InputBorder.none,
          ),
          validator: (value) => value!.isEmpty ? "Campo obbligatorio" : null,
        ),
      ),
    );
  }

  Widget _buildDropdown({required String label, required List<String> items, required String? value, required Function(String?) onChanged}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required String text, required Color color, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
        final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Nuovo Avvistamento", style: TextStyle(fontWeight: FontWeight.bold)),        backgroundColor: theme.colorScheme.primary),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInputField(controller: _esemplariController, label: "Numero di esemplari", icon: Icons.numbers, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildButton(text: "Ottieni Posizione GPS", color: Colors.blue, icon: Icons.location_on, onPressed: _getCurrentLocation),
              const SizedBox(height: 16),
              _buildDropdown(label: "Animale", items: animali, value: _selectedAnimale, onChanged: (val) => setState(() => _selectedAnimale = val)),
              const SizedBox(height: 16),
              _buildDropdown(label: "Specie", items: _selectedAnimale != null ? specieMap[_selectedAnimale]! : [], value: _selectedSpecie, onChanged: (val) => setState(() => _selectedSpecie = val)),
              const SizedBox(height: 16),
              _buildInputField(controller: _mareController, label: "Mare", icon: Icons.waves),
              const SizedBox(height: 16),
              _buildInputField(controller: _ventoController, label: "Vento", icon: Icons.air),
              const SizedBox(height: 16),
              _buildInputField(controller: _noteController, label: "Note", icon: Icons.note),
              const SizedBox(height: 16),
              _buildButton(text: "Carica  immagine", color: Colors.blue, icon: Icons.photo, onPressed: _saveAvvistamento),
              const SizedBox(height: 32),

              _buildButton(text: "Salva Avvistamento", color: Colors.green, icon: Icons.save, onPressed: _saveAvvistamento),
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
import 'package:seawatch/screens/HomepageScreen.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';


import 'package:seawatch/screens/avvistamenti/AggiungiImmaginiScreen.dart';

class NuovoAvvistamentoScreen extends StatefulWidget {
  final String userEmail;

  NuovoAvvistamentoScreen({required this.userEmail});

  @override
  _NuovoAvvistamentoScreenState createState() => _NuovoAvvistamentoScreenState();
}

class _NuovoAvvistamentoScreenState extends State<NuovoAvvistamentoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _esemplariController = TextEditingController();
  final TextEditingController _mareController = TextEditingController();
  final TextEditingController _ventoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _latitude;
  String? _longitude;

  bool _isSaving = false;
  String? _selectedAnimale;
  String? _selectedSpecie;

  List<String> animali = ['Delfino', 'Balena', 'Squalo', 'Tartaruga'];
  Map<String, List<String>> specieMap = {
    'Delfino': ['Tursiope', 'Stenella'],
    'Balena': ['Balena Blu', 'Capodoglio'],
    'Squalo': ['Squalo Bianco', 'Squalo Martello'],
    'Tartaruga': ['Caretta', 'Liuto'],
  };

Future<void> _getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // 1️⃣ Controllo se il GPS è attivo
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("GPS disattivato! Attivalo per ottenere la posizione.")));
    return;
  }

  // 2️⃣ Controllo lo stato dei permessi
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Permesso di accesso alla posizione negato.")));
      return;
    }
  }

  // 3️⃣ Se i permessi sono negati PERMANENTEMENTE, mostra un messaggio
  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Permessi di posizione negati permanentemente. Vai nelle impostazioni per abilitarli."),
        action: SnackBarAction(
          label: "Apri Impostazioni",
          onPressed: () {
            Geolocator.openAppSettings();
          },
        ),
      ),
    );
    return;
  }

  // 4️⃣ Se tutto è ok, ottieni la posizione
  try {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Posizione acquisita con successo!")));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore nell'ottenere la posizione: $e")));
  }
}


  /// **🌍 Funzione per inviare l'avvistamento (mia logica)**
Future<void> _sendAvvistamento() async {
  //if (!_formKey.currentState!.validate()) return;
  if (_latitude == null || _longitude == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Devi ottenere la posizione GPS!")));
    return;
  }

  setState(() => _isSaving = true);

  const url = 'https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_sighting/sighting_api.php';
  
  // Genera un ID unico   // Genera un ID univoco come intero basato sul timestamp attuale

  String avvistamentoId = DateTime.now().millisecondsSinceEpoch.toString();

  final body = {
    'request': 'saveAvvMob',
    'idd': avvistamentoId, // Passa l'ID generato
    'user': widget.userEmail,
    'data': DateTime.now().toIso8601String(),
    'esemplari': _esemplariController.text,
    'latitudine': _latitude!,
    'longitudine': _longitude!,
    'specie': _selectedAnimale ?? '',
    'sottospecie': _selectedSpecie ?? '',
    'mare': _mareController.text,
    'vento': _ventoController.text,
    'note': _noteController.text,
  };

  try {
    var response = await http.post(Uri.parse(url), body: body);
    if (response.statusCode == 200 && response.body == "true") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Avvistamento salvato con successo!")));

      // Passa l'ID generato alla schermata successiva
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AggiungiImmaginiScreen(avvistamentoId: avvistamentoId)),

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("Nuovo Avvistamento"), backgroundColor: theme.colorScheme.primary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _esemplariController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Numero di esemplari", icon: Icon(Icons.numbers)),
                validator: (value) => value!.isEmpty ? "Campo obbligatorio" : null,
              ),
              SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: Icon(Icons.location_on),
                label: Text(_latitude == null ? "Ottieni Posizione GPS" : "Posizione acquisita!"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),

              SizedBox(height: 16),

              DropdownButtonFormField(
                value: _selectedAnimale,
                items: animali.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedAnimale = val),
                decoration: InputDecoration(labelText: "Animale", icon: Icon(Icons.pets)),
              ),

              SizedBox(height: 16),

              DropdownButtonFormField(
                value: _selectedSpecie,
                items: _selectedAnimale != null ? specieMap[_selectedAnimale!]!.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList() : [],
                onChanged: (val) => setState(() => _selectedSpecie = val as String?),
                decoration: InputDecoration(labelText: "Specie", icon: Icon(Icons.category)),
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: _mareController,
                decoration: InputDecoration(labelText: "Mare", icon: Icon(Icons.waves)),
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _ventoController,
                decoration: InputDecoration(labelText: "Vento", icon: Icon(Icons.air)),
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: "Note", icon: Icon(Icons.note)),
              ),

              SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _sendAvvistamento,
                icon: Icon(Icons.save),
                label: Text(_isSaving ? "Salvando..." : "Salva Avvistamento"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
