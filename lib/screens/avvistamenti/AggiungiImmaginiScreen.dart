import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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

  // Metodo per selezionare più immagini
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(); // Selezione multipla

    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  // Metodo per caricare le immagini
  
Future<void> _uploadImages() async {
  if (_images.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nessuna immagine selezionata."))
    );
    return;
  }

  setState(() => isLoading = true); // Mostra il caricamento

  for (var image in _images) {
    bool success = await uploadImage(image, int.parse(widget.avvistamentoId), context);
    
    if (!success) {
      // Se una delle immagini fallisce, mostriamo un errore e interrompiamo il caricamento
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore nel caricamento di un'immagine."))
      );
      return;
    }
  }

  setState(() => isLoading = false); // Nasconde il caricamento

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Tutte le immagini caricate con successo!"))
  );
}


Future<bool> uploadImage(File imageFile, int idAvvistamento, BuildContext context) async {
  try {
    var url = "https://isi-seawatch.csr.unibo.it/Sito/sito/templates/single_sighting/single_api.php";
    var uri = Uri.parse(url);
    print("URL: '$url'");

    var request = http.MultipartRequest("POST", uri);
    request.fields['request'] = 'addImage';
    request.fields['id'] = idAvvistamento.toString(); // L'ID deve essere una stringa numerica
    request.fields['fileName'] = imageFile.uri.pathSegments.last; // Aggiungi il nome del file

    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path, contentType: MediaType('image', 'jpeg')));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    print("📡 Risposta completa: $responseData");

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(responseData);
      if (jsonResponse['state'] == true) {
        print("✅ Immagine caricata correttamente!");
        return true;
      }
    }
  } catch (e) {
    print("⚠️ Errore durante il caricamento dell'immagine: $e");
  }
  return false;
}



/*
Future<void> _uploadSingleImage(File image) async {
  try {
    var url = Uri.parse("https://isi-seawatch.csr.unibo.it/Sito/sito/templates/single_sighting/single_api.php");

    var request = http.MultipartRequest("POST", url);
    request.fields['request'] = 'addImage';
    request.fields['id'] = widget.avvistamentoId;
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    print("📡 Risposta completa: $responseData"); // STAMPA LA RISPOSTA API COMPLETA

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(responseData); // Prova a decodificare il JSON
      if (jsonResponse.containsKey('success') && jsonResponse['success'] == true) {
        print("✅ Immagine caricata e salvata con successo!");
      } else {
        print("❌ La risposta API non indica un vero salvataggio: $jsonResponse");
      }
    } else {
      print("❌ Errore HTTP ${response.statusCode}: $responseData");
    }
  } catch (e) {
    print("⚠️ Errore durante il caricamento: $e");
  }
}

*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Aggiungi Immagini"), backgroundColor: Colors.blue.shade800),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImages,
              child: Text("Seleziona Immagini"),
            ),
            const SizedBox(height: 10),
            _images.isNotEmpty
                ? Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Image.file(_images[index], fit: BoxFit.cover),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _images.removeAt(index);
                                  });
                                },
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  )
                : Text("Nessuna immagine selezionata"),
            const SizedBox(height: 20),
           
        isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadImages,
                    child: Text("Carica Immagini"),
                  ),

          ],
        ),
      ),
    );
  }
}
