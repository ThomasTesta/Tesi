import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seawatch/services/UploadService.dart';

// Schermata per aggiungere immagini a un avvistamento
class AggiungiImmaginiScreen extends StatefulWidget {
  final String avvistamentoId;
  AggiungiImmaginiScreen({required this.avvistamentoId});
  @override
  _AggiungiImmaginiScreenState createState() => _AggiungiImmaginiScreenState();
}

class _AggiungiImmaginiScreenState extends State<AggiungiImmaginiScreen> {
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  // Seleziona immagini dalla galleria
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  // Scatta una foto
  Future<void> _uploadImages() async {
    if (_images.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nessuna immagine selezionata.")),
      );
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    for (var image in _images) {
      bool success = await UploadService.uploadImage(
          image, int.parse(widget.avvistamentoId));
      if (!mounted) return;
      if (!success) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore nel caricamento di un'immagine.")),
        );
        return;
      }
    }

    if (!mounted) return;
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tutte le immagini caricate con successo!")),
    );
  }

  //Interfaccia utente
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Aggiungi Immagini")),
      body: Column(
        children: [
          SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: Icon(Icons.photo_library),
                label: Text("Galleria"),
              ),
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: Icon(Icons.camera_alt),
                label: Text("Fotocamera"),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: _images.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.file(_images[index], fit: BoxFit.cover),
              ),
            ),
          ),
          isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _uploadImages,
                  child: Text("Carica Immagini"),
                ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
