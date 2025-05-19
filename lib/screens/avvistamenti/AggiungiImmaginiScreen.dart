//librerie
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart'; 
import 'package:image_picker/image_picker.dart'; 
import 'package:http/http.dart' as http; 

class AggiungiImmaginiScreen extends StatefulWidget {

  final String avvistamentoId; // ID dell’avvistamento a cui associare le immagini
  AggiungiImmaginiScreen({required this.avvistamentoId});

  @override
  _AggiungiImmaginiScreenState createState() => _AggiungiImmaginiScreenState();
}

class _AggiungiImmaginiScreenState extends State<AggiungiImmaginiScreen> {
  List<File> _images = []; // Lista di immagini selezionate
  final ImagePicker _picker = ImagePicker(); 
  bool isLoading = false; // Stato per indicare se il caricamento è in corso


 // Metodo per selezionare più immagini dalla galleria
 Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(); // Selezione multipla di immagini

    if (pickedFiles != null) {
      // Convertiamo le immagini da XFile a File
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }


 // Metodo per scattare una foto con la fotocamera
 Future<void> _takePhoto() async {
  final pickedFile = await _picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null) {
    setState(() {
      _images.add(File(pickedFile.path));
    });
  }
}

 // Metodo per caricare tutte le immagini selezionate
 Future<void> _uploadImages() async {
    // Controlla se ci sono immagini selezionate
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nessuna immagine selezionata."))
      );
      return;
    }

    setState(() => isLoading = true); // Mostra indicatore di caricamento

    // Cicla su ogni immagine e la carica singolarmente
    for (var image in _images) {
      bool success = await uploadImage(image, int.parse(widget.avvistamentoId), context);

      // Se una delle immagini fallisce, mostra errore e ferma il caricamento
      if (!success) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore nel caricamento di un'immagine."))
        );
        return;
      }
    }

    // Tutto è andato a buon fine
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tutte le immagini caricate con successo!"))
    );
  }

  // Metodo per caricare una singola immagine al server
 Future<bool> uploadImage(File imageFile, int idAvvistamento, BuildContext context) async {
    try {
      // URL dell’API che gestisce l’upload delle immagini
      var url = "https://isi-seawatch.csr.unibo.it/Sito/sito/templates/single_sighting/single_api.php";
      var uri = Uri.parse(url);

      print("URL: '$url'");

      // Costruzione della richiesta HTTP Multipart
      var request = http.MultipartRequest("POST", uri);
      request.fields['request'] = 'addImage'; 
      request.fields['id'] = idAvvistamento.toString(); // ID dell’avvistamento
      request.fields['fileName'] = imageFile.uri.pathSegments.last; // Nome del file

      // Aggiunge il file immagine al corpo della richiesta
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'), // Specifica il tipo MIME
        ),
      );

      // Invia la richiesta
      var response = await request.send();

      // Legge la risposta in formato stringa
      var responseData = await response.stream.bytesToString();

      print("📡 Risposta completa: $responseData");

      // Se la risposta HTTP è OK (200), controlla lo stato nel JSON
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

    // In caso di errore, ritorna false
    return false;
  }


  // Metodo NON UTILIZZATO (alternativa per caricare una singola immagine)
  Future<void> _uploadSingleImage(File image) async {
    try {
      var url = Uri.parse("https://isi-seawatch.csr.unibo.it/Sito/sito/templates/single_sighting/single_api.php");

      var request = http.MultipartRequest("POST", url);
      request.fields['request'] = 'addImage';
      request.fields['id'] = widget.avvistamentoId;

      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("📡 Risposta completa: $responseData");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);

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

// Metodo che costruisce l'interfaccia utente
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
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