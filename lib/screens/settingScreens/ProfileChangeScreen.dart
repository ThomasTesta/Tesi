import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
/*
class ProfileChangeScreen extends StatefulWidget {
  const ProfileChangeScreen({Key? key}) : super(key: key);

  @override
  _ProfileChangeScreenState createState() => _ProfileChangeScreenState();
}

class _ProfileChangeScreenState extends State<ProfileChangeScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
        title: const Text('Modifica Profilo'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Cognome',
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final success = await _updateUserInfo();
                      if (success) {
                        Navigator.pop(context, true); // Ritorna alla schermata precedente
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Salva'),
                  ),
                ],
              ),
            ),
    );
  }
}
*/

import 'dart:io';
import 'dart:convert';
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
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstNameController.text = prefs.getString('firstName') ?? 'Mario';
      lastNameController.text = prefs.getString('lastName') ?? 'Rossi';
    });
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
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Scatta una foto'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
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
                    _buildInputField(
                      controller: firstNameController,
                      label: 'Nome',
                      icon: Icons.person,
                      isBold: true,
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      controller: lastNameController,
                      label: 'Cognome',
                      icon: Icons.person_outline,
                      isBold: true,
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      text: 'Aggiorna immagine del profilo',
                      color: theme.colorScheme.secondary,
                      icon: Icons.image,
                      onPressed: _pickImage,
                    ),
                    const SizedBox(height: 10),
                    _buildButton(
                      text: 'Salva',
                      color: theme.colorScheme.primary,
                      icon: Icons.save,
                      onPressed: () async {
                        // Simuliamo il salvataggio con un breve delay
                        setState(() => isLoading = true);
                        await Future.delayed(const Duration(seconds: 2));
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

