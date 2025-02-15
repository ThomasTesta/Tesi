import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AggiungiImmaginiScreen extends StatefulWidget {
  final String avvistamentoId;

  AggiungiImmaginiScreen({required this.avvistamentoId});

  @override
  _AggiungiImmaginiScreenState createState() => _AggiungiImmaginiScreenState();
}

class _AggiungiImmaginiScreenState extends State<AggiungiImmaginiScreen> {
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null && _images.length < 5) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _uploadImages() async {
    const url = 'https://isi-seawatch.csr.unibo.it/Sito/sito/templates/main_sighting/sighting_api.php';

    try {
      for (var image in _images) {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.fields['request'] = 'uploadImage';
        request.fields['avvistamentoId'] = widget.avvistamentoId;
        request.files.add(await http.MultipartFile.fromPath('image', image.path, contentType: MediaType('image', 'jpeg')));
        
        var response = await request.send();

        if (response.statusCode == 200) {
          print("Immagine caricata con successo.");
        } else {
          print("Errore nel caricamento dell'immagine.");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Immagini caricate con successo!")));
      Navigator.pop(context); // Torna alla schermata precedente
    } catch (e) {
      print("Errore durante il caricamento delle immagini: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Aggiungi Immagini"), backgroundColor: Colors.blue.shade800),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: _pickImage, child: Text("Seleziona Immagine")),
            SizedBox(height: 16),
            Wrap(children: _images.map((img) => Image.file(img, height: 100)).toList()),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadImages,
              child: Text("Carica Immagini"),
            ),
          ],
        ),
      ),
    );
  }
}
