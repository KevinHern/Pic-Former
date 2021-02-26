// Basic
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

// Models
import 'package:time_shifter/models/progress.dart';

// Backend
import 'package:http/http.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIHTTPRequest {
  static Future getTemporaryFile(String tempFileName) async {
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/' + tempFileName +  '.jpg');
    return tempFile;
  }

  static Future getAILink(int server) async {
    final CollectionReference misc = FirebaseFirestore.instance.collection('miscellaneous');
    return await misc.doc("aiserver").get().then((
        snapshot) {
      if(snapshot.exists) {
        return snapshot.get("server" + server.toString());
      }
    });
  }

  static Future<File> fileFromImageUrl(int server, String fileName, ProgressDialogWrapper pdw, int alteredNoPicture) async {
    // Getting Server Link
    String aiServerLink = await getAILink(1);
    pdw.updateProgressDialog("Obteniendo Imagen...", 2);

    // Getting Image from GET
    final fileURL = aiServerLink + "/retrieve?filename=" + fileName;
    final response = await get(fileURL);
    pdw.updateProgressDialog("Procesando Imagen...", 2);
    print(fileURL);

    // Writing file
    File file = await getTemporaryFile('altered' + alteredNoPicture.toString());
    file.writeAsBytesSync(response.bodyBytes);

    return file;
  }

  static Future alterImageRequest(int server, File originalPic, ProgressDialogWrapper pdw) async {

    // Making POST request
    String aiServerLink = await getAILink(1);
    String url = aiServerLink + "/transform";
    Map<String, String> headers = {"Content-type": "application/json", "Connection": "Keep-Alive"};

    // Making JSON Body
    pdw.updateProgressDialog("Enviando Imagen...", 2);
    String json = '{"img": ' + originalPic.readAsBytesSync().toString();
    json += ', "imgext": "' + originalPic.path.split('.').last + '"';
    json += ', "isgrayscale": ' + (server != 1).toString();
    json += '}';

    // Do request
    //print("Sending request");
    Response response = await post(url, headers: headers, body: json);

    //print("Got response");
    // Check Status
    if(response.statusCode == 200){
      Map<String, dynamic> recvJson = JsonDecoder().convert(response.body);

      pdw.updateProgressDialog("Esperando a que se termine de transformar...", 3);

      if(recvJson['name'] == null) throw Exception('An error ocurred in the backend');
      else return recvJson['name'];
    }
    else {
      return null;
    }
  }
}