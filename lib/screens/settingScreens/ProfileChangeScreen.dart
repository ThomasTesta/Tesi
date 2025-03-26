/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class ProfileChangeScreen extends StatefulWidget {
  const ProfileChangeScreen({Key? key}) : super(key: key);

  @override
  _ProfileChangeScreenState createState() => _ProfileChangeScreenState();
}

class _ProfileChangeScreenState extends State<ProfileChangeScreen> {
  // Controller per i campi di testo (nome e cognome)
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  File? _image; // Variabile per memorizzare l'immagine selezionata
  final ImagePicker _picker = ImagePicker(); // Oggetto per gestire la selezione delle immagini
  bool isLoading = false; // Stato per gestire il caricamento

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Carica i dati utente salvati nelle preferenze
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstNameController.text = prefs.getString('firstName') ?? 'Mario';
      lastNameController.text = prefs.getString('lastName') ?? 'Rossi';
    });
  }

  Future<void> _saveUserDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstNameController.text);
    await prefs.setString('lastName', lastNameController.text);
  }

  Future<bool> _updateUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore: Utente non loggato')),
      );
      return false;
    }

    if (firstNameController.text.trim().isEmpty || lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e cognome non possono essere vuoti')),
      );
      return false;
    }

    final url = Uri.parse('https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_settings/settings_api.php');
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      url,
      body: {
        'request': 'setUserInfoMob',
        'user': email,
        'nome': firstNameController.text.trim(),
        'cognome': lastNameController.text.trim(),
      },
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      try {
        final result = json.decode(response.body);

        if (result is Map<String, dynamic> && result['stato'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dati aggiornati con successo')),
          );
          await _saveUserDataLocally(); // Salva i nuovi dati localmente
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore: ${result["msg"] ?? "Errore sconosciuto"}')),
          );
          return false;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nel formato della risposta dal server')),
        );
        return false;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore di comunicazione con il server')),
      );
      return false;
    }
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleziona un\'opzione'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Scatta una foto'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Scegli dalla galleria'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Profilo', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar circolare cliccabile per selezionare un'immagine
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: _image != null ? FileImage(_image!) : null,
                        backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                        child: _image == null
                            ? Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: theme.colorScheme.onBackground.withOpacity(0.5),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Campo input per il nome
                    _buildInputField(
                      controller: firstNameController,
                      label: 'Nome',
                      icon: Icons.person,
                      isBold: true,
                    ),
                    const SizedBox(height: 10),
                    // Campo input per il cognome
                    _buildInputField(
                      controller: lastNameController,
                      label: 'Cognome',
                      icon: Icons.person_outline,
                      isBold: true,
                    ),
                    const SizedBox(height: 20),
                    // Pulsante per aggiornare l'immagine del profilo
                    _buildButton(
                      text: 'Aggiorna immagine del profilo',
                      color: theme.colorScheme.secondary,
                      icon: Icons.image,
                      onPressed: _pickImage,
                    ),
                    const SizedBox(height: 10),
                    // Pulsante per salvare le modifiche
                    _buildButton(
                      text: 'Salva',
                      color: theme.colorScheme.primary,
                      icon: Icons.save,
                      onPressed: () async {
                        setState(() => isLoading = true);
                        await Future.delayed(const Duration(seconds: 2)); // Simulazione salvataggio
                        setState(() => isLoading = false);
                        Navigator.pop(context, true);
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Funzione per creare un campo di input
  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon, bool isBold = false}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Funzione per creare un pulsante
  Widget _buildButton({required String text, required Color color, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

*/

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ProfileChangeScreen extends StatefulWidget {
  const ProfileChangeScreen({Key? key}) : super(key: key);

  @override
  _ProfileChangeScreenState createState() => _ProfileChangeScreenState();
}

class _ProfileChangeScreenState extends State<ProfileChangeScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    //_loadUserDataFromServer();
  }

  /*

  Future<void> _loadUserDataFromServer() async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('userEmail'); // L'email dell'utente

  if (email == null) {
    print('Errore: Nessun email trovata nei dati salvati.');
    return;
  }

  final url = Uri.parse('https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_settings/settings_api.php'); // URL dell'API
  try {
    print('Invio richiesta al server per caricare i dati dell\'utente...');
    final response = await http.post(
      url,
      body: json.encode({
        'action': 'getUserInfoMob',
        'user': email,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('Codice di risposta: ${response.statusCode}');
    print('Risposta dal server: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final result = json.decode(response.body);
        print('JSON decodificato: $result');

        if (result is Map<String, dynamic> && result['stato'] == true) {
          final userData = result['data'];
          setState(() {
            firstNameController.text = userData['nome'] ?? 'Nome';
            lastNameController.text = userData['cognome'] ?? 'Cognome';
          });
          print('Dati utente caricati: Nome: ${firstNameController.text}, Cognome: ${lastNameController.text}');
        } else {
          print('Errore nei dati del server: ${result["msg"] ?? "Errore sconosciuto"}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore: ${result["msg"] ?? "Errore sconosciuto"}')),
          );
        }
      } catch (e) {
        print('Errore durante il parsing del JSON: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formato della risposta non valido')),
        );
      }
    } else {
      print('Errore di comunicazione con il server. Codice: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore di comunicazione con il server: ${response.statusCode}')),
      );
    }
  } catch (e) {
    print('Errore durante la comunicazione col server: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Errore durante la comunicazione con il server')),
    );
  }
}
*/
Future<bool> _updateUserInfo() async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('userEmail');

  if (email == null) {
    _showSnackBar('Errore: Utente non loggato');
    return false;
  }

  final url = Uri.parse('https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_settings/settings_api.php');
  final requestBody = {
    'request': 'setUserInfoMob',
    'user': email,
    'nome': firstNameController.text,
    'cognome': lastNameController.text,
  };

  print('Invio richiesta UPDATE USER INFO con email: $email');
  print('Dati inviati: $requestBody');

  try {
    final response = await http.post(url, body: requestBody);

    print('Risposta ricevuta: ${response.body}');

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['stato'] == true) {
        _showSnackBar('Dati aggiornati con successo');
        return true;
      }
    } else {
      print('Errore HTTP: ${response.statusCode}');
    }
  } catch (e) {
    print('Errore: $e');
    _showSnackBar('Errore durante il salvataggio');
  }
  return false;
}

Future<bool> uploadImage(File file, String user) async {
  final url = Uri.parse("https://isi-seawatch.csr.unibo.it/Sito/sito/templates/single_sighting/single_api.php");

  print('Inizio caricamento immagine per utente: $user');
  print('File selezionato: ${file.uri.pathSegments.last}');

  try {
    final request = http.MultipartRequest('POST', url)
      ..fields['user'] = user
      ..fields['request'] = "addImageProfileMob"
      ..files.add(
        http.MultipartFile(
          'file',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.uri.pathSegments.last,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    print('Dati inviati: ${request.fields}');
    
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print('Risposta ricevuta: $responseBody');

    if (response.statusCode == 200) {
      final result = json.decode(responseBody);
      if (result['state'] == true) {
        _showSnackBar('Immagine caricata con successo');
        return true;
      }
    } else {
      print('Errore HTTP: ${response.statusCode}');
    }
  } catch (e) {
    print('Errore: $e');
    _showSnackBar('Errore durante il caricamento');
  }
  return false;
}


  Future<void> _pickImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleziona un opzione'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Scatta una foto'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Scegli dalla galleria'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Profilo', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar circolare cliccabile per selezionare un'immagine
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: _image != null ? FileImage(_image!) : null,
                        backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                        child: _image == null
                            ? Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: theme.colorScheme.onBackground.withOpacity(0.5),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Campo input per il nome
                    _buildInputField(
                      controller: firstNameController,
                      label: 'Nome',
                      icon: Icons.person,
                      isBold: true,
                    ),
                    const SizedBox(height: 10),
                    // Campo input per il cognome
                    _buildInputField(
                      controller: lastNameController,
                      label: 'Cognome',
                      icon: Icons.person_outline,
                      isBold: true,
                    ),
                    const SizedBox(height: 20),
                    // Pulsante per aggiornare l'immagine del profilo
                    _buildButton(
                      text: 'Aggiorna immagine del profilo',
                      color: theme.colorScheme.secondary,
                      icon: Icons.image,
                      onPressed: _pickImage,
                    ),
                    const SizedBox(height: 10),
                    // Pulsante per salvare le modifiche
_buildButton(
  text: 'Salva',
  color: theme.colorScheme.primary,
  icon: Icons.save,
  onPressed: () async {
    setState(() => isLoading = true);
    
    bool success = await _updateUserInfo();

    setState(() => isLoading = false);

    if (success) {
      Navigator.pop(context, true);
    }
  },
),

                  ],
                ),
              ),
      ),
    );
  }

  // Funzione per creare un campo di input
  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon, bool isBold = false}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Funzione per creare un pulsante
  Widget _buildButton({required String text, required Color color, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}