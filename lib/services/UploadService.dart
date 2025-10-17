import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

// Servizio per caricare immagini al server
class UploadService {
  static Future<bool> uploadImage(File imageFile, int idAvvistamento) async {
    try {
      var url = "https://isi-seawatch.csr.unibo.it/Sito/sito/templates/single_sighting/single_api.php";
      var uri = Uri.parse(url);

      var request = http.MultipartRequest("POST", uri);
      request.fields['request'] = 'addImage';
      //request id perchè immagini e avvistamento separati
      request.fields['id'] = idAvvistamento.toString();

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType:
              MediaType('image', lookupMimeType(imageFile.path)!.split('/')[1]),
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        return jsonResponse['state'] == true;
      }
    } catch (e) {
      print("⚠️ Errore durante l'upload: $e");
    }
    return false;
  }
}
