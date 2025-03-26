
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seawatch/screens/authentication/LoginScreen.dart';
import 'package:seawatch/screens/settingScreens/ProfileChangeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/*
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Carica i dati dell'utente loggato
  }

Future<void> _loadUserData() async {
  // Carica i dati locali
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    firstNameController.text = prefs.getString('firstName') ?? 'Mario';
    lastNameController.text = prefs.getString('lastName') ?? 'Rossi';
    emailController.text = prefs.getString('userEmail') ?? 'mario.rossi@example.com';

    final imagePath = prefs.getString('profileImage');
    if (imagePath != null) {
      _image = File(imagePath);
    }
  });

  // Tenta di aggiornare i dati dal server
  await _loadUserDataFromServer();
}




  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstNameController.text);
    await prefs.setString('lastName', lastNameController.text);
    await prefs.setString('userEmail', emailController.text);

    print('Dati salvati con successo');
  }

Future<void> _pickImage() async {
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      _image = File(pickedFile.path);
    });

    // Salva il percorso dell'immagine nei dati locali
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImage', pickedFile.path);
  }
}

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Rimuove tutti i dati salvati
    Navigator.pushReplacementNamed(context, '/login'); // Torna alla schermata di login
  }
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
            firstNameController.text = userData['nome'] ?? 'Mario';
            lastNameController.text = userData['cognome'] ?? 'Rossi';
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


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  backgroundColor: colorScheme.secondary.withOpacity(0.1),
                  child: _image == null
                      ? Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: colorScheme.onBackground.withOpacity(0.5),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: colorScheme.onSurface),
                  prefixIcon: Icon(Icons.person, color: colorScheme.primary),
                  filled: true,
                  fillColor: colorScheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Cognome',
                  labelStyle: TextStyle(color: colorScheme.onSurface),
                  prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
                  filled: true,
                  fillColor: colorScheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: colorScheme.onSurface),
                  prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                  filled: true,
                  fillColor: colorScheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
const SizedBox(height: 20),
ElevatedButton(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileChangeScreen()),
    );

    if (result == true) {
      _loadUserData(); // Ricarica i dati aggiornati
    }
  },
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    backgroundColor: colorScheme.secondary,
  ),
  child: const Text(
    'Modifica Profilo',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}

*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:seawatch/screens/authentication/LoginScreen.dart';
import 'package:seawatch/screens/settingScreens/ProfileChangeScreen.dart';
import 'package:seawatch/services/AuthServiceGeneral/AuthService.dart';

class ProfileScreen extends StatefulWidget {
  final String email;

  const ProfileScreen({Key? key, required this.email}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? profileImageUrl;
  String? firstName;
  String? lastName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    const String apiUrl =
        'https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_settings/settings_api.php';
    const String imageBaseUrl = 'https://isi-seawatch.csr.unibo.it/Sito/img/profilo/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'user': widget.email,
          'request': 'getUserInfoMob',
        },
      );

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.isNotEmpty) {
          final data = json.decode(body);

          if (data is List && data.isNotEmpty) {
            final userInfo = data[0];

            setState(() {
              profileImageUrl = userInfo['Img'] != null && userInfo['Img'].isNotEmpty
                  ? imageBaseUrl + userInfo['Img']
                  : null;
              firstName = userInfo['Nome'];
              lastName = userInfo['Cognome'];
              isLoading = false;
            });
          } else {
            setState(() {
              profileImageUrl = null;
              firstName = null;
              lastName = null;
              isLoading = false;
            });
          }
        } else {
          debugPrint('Errore: il server ha restituito una risposta vuota.');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        debugPrint('Errore nella richiesta: codice ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Eccezione durante la richiesta HTTP: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo Utente', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: theme.colorScheme.primary,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!) // Carica immagine dal server
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, size: 80, color: Colors.white) // Placeholder
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  '${firstName ?? "Nome"} ${lastName ?? "Cognome"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileChangeScreen()),
                    );
                    if (result == true) {
                      fetchProfileData();
                    }
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text('Modifica Profilo', style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
