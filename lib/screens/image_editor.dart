// Basic
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as I;

// Models
import 'package:time_shifter/models/progress.dart';
import 'package:time_shifter/templates/navbar_template.dart';

// Templates
import 'package:time_shifter/templates/container_template.dart';
import 'package:time_shifter/templates/dialog_template.dart';

// Backend
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_shifter/backend/aihttp.dart';

class ImageEditor extends StatelessWidget {
  final int aiMode;
  ImageEditor(int aiMode, {Key key}) : this.aiMode = aiMode;

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildAppBar(
      context,
      const [0xFF000051, 0xFF534bae, 0xFFFFFFFF],
      (this.aiMode == 1) ? 'Nochenizar' : "Colorizar",
      new ImageEditorScreen(this.aiMode),
    );
  }
}

class ImageEditorScreen extends StatefulWidget {
  final int aiMode;
  ImageEditorScreen(int aiMode, {Key key}) : this.aiMode = aiMode;

  ImageEditorState createState() => ImageEditorState(this.aiMode);
}

class ImageEditorState extends State<ImageEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final int aiMode;
  final String collection;
  ImageEditorState(int aiMode, {Key key})
      : this.aiMode = aiMode,
        this.collection = (aiMode == 1) ? "nightirizer" : "colorized";

  bool showCapturedPhoto, showAlteredPhoto, showFetchPhoto;
  File imageFile, imageAltered;
  String userName, alteredName;
  TextEditingController _userNameController;
  int tempImageNumber;
  final List<int> colors = [0xFF1a237e, 0xFF534bae, 0xFF000051, 0xFFFFFFFF];

  @override
  void initState() {
    super.initState();
    this._userNameController = new TextEditingController();
    this._userNameController.text = "";
    this.tempImageNumber = 0;
    this.showCapturedPhoto = false;
    this.showFetchPhoto = false;
    this.showAlteredPhoto = false;
  }

  Future askName() async {
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return new AlertDialog(
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Container(
                  height: 40,
                  width: 40,
                  child: new Image.asset('assets/images/help.png'),
                ),
                new Padding(
                  padding: new EdgeInsets.only(left: 15),
                  child: new Text('Ingrese su Nombre'),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: new SingleChildScrollView(
              child: new TextFormField(
                controller: this._userNameController,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  this.userName = this._userNameController.text;
                  Navigator.of(context).pop();
                },
                child: new Container(
                  height: 30,
                  width: 30,
                  child: Image.asset('assets/images/confirm.png'),
                ),
              ),
            ],
          );
        });
  }

  Widget _buidTakePictureButton() {
    return new Padding(
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () async {
          try {
            // Capturing
            imageCache.clear();
            this.tempImageNumber++;
            final PickedFile photo = await (new ImagePicker()).getImage(
              source: ImageSource.camera,
              imageQuality: 50,
              maxHeight: 256.0,
              maxWidth: 256.0,
            );

            // Resizing
            final img = I.decodeImage(new File(photo.path).readAsBytesSync());
            final fimg = I.copyResize(img, width: 256, height: 256);

            // Getting final image
            if (this.imageFile != null) this.imageFile.deleteSync();
            this.imageFile = await AIHTTPRequest.getTemporaryFile(
                'original' + this.tempImageNumber.toString());
            this.imageFile.writeAsBytesSync(I.encodeJpg(fimg));

            // Scaling to [-1, 1]

            setState(() {
              this.showCapturedPhoto = true;
              this.showFetchPhoto = false;
              this.showAlteredPhoto = false;
            });
          } catch (e) {
            print(e);
          }
        },
        color: Color(this.colors[2]),
        textColor: Color(this.colors[3]),
        child: Text(
          "Abrir\nCámara",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _editorButton() {
    return new Padding(
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () async {
          if (this.imageFile == null) {
            DialogTemplate.showMessage(
                context, "No has tomado ninguna foto", "Aviso");
          } else {
            final ProgressDialogWrapper pd = ProgressDialogWrapper(
                context, 'Revisando disponibilidad del servidor...', 3);
            String response;
            try {
              // Show Progress
              await pd.showProgressDialog();

              // HTTP request
              response = await AIHTTPRequest.alterImageRequest(
                  this.aiMode, this.imageFile, pd);
              print(response);
              this.showAlteredPhoto = false;
              this.showFetchPhoto = false;
            } catch (exception) {
              print(exception);
            }

            await pd.dismissProgressDialog();

            setState(() {});
            if (response != null) {
              this.alteredName = response;
              this.showFetchPhoto = true;
              DialogTemplate.showMessage(
                  context, "Imagen alterada exitosamente", "Aviso");
            } else {
              DialogTemplate.showMessage(
                  context, "Ocurrió un error, intenta de nuevo", "Aviso");
            }
          }
        },
        color: Color(this.colors[2]),
        textColor: Color(this.colors[3]),
        child: Text("Alterar", style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildFetchButton() {
    return new Padding(
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () async {
          final ProgressDialogWrapper pd = ProgressDialogWrapper(
              context, 'Revisando disponibilidad del servidor...', 3);
          try {
            // Show Progress
            await pd.showProgressDialog();
            if (this.imageAltered != null) this.imageAltered.deleteSync();
            this.imageAltered = await AIHTTPRequest.fileFromImageUrl(
                1, this.alteredName, pd, this.tempImageNumber);
          } catch (e) {
            print(e);
          }
          await pd.dismissProgressDialog();
          if (this.imageAltered != null) {
            this.showAlteredPhoto = true;
            DialogTemplate.showMessage(
                context, "Imagen obtenida exitosamente", "Aviso");
          } else {
            DialogTemplate.showMessage(
                context, "Ocurrió un error, intenta de nuevo", "Aviso");
          }
          setState(() {});
        },
        color: Color(this.colors[2]),
        textColor: Color(this.colors[3]),
        child: Text(
          "Obtener Imagen Alterada",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return new Padding(
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () async {
          int code = 0;

          final ProgressDialogWrapper pd =
              ProgressDialogWrapper(context, 'Procesando Imagen...', 3);
          await pd.showProgressDialog();
          try {
            while (this._userNameController.text.isEmpty ||
                this._userNameController.text.trim().isEmpty) {
              this._userNameController.text = "";
              await this.askName();
            }

            // Getting Device ID
            final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();

            String identifier;
            if (Platform.isAndroid) {
              var build = await deviceInfoPlugin.androidInfo;
              identifier = build.androidId;
            } else if (Platform.isIOS) {
              var data = await deviceInfoPlugin.iosInfo;
              identifier = data.identifierForVendor;
            } else {
              throw PlatformException();
            }

            int timestamp = DateTime.now().millisecondsSinceEpoch;

            // Uploading to Firebase Storage
            pd.updateProgressDialog("Subiendo Imagen: paso 1 de 2...", 2);

            FirebaseStorage storage = FirebaseStorage.instance;
            Reference storef = storage
                .ref()
                .child(identifier + "/" + timestamp.toString() + ".jpg");
            await storef.putFile(this.imageAltered);

            // Uploading to Firestore
            pd.updateProgressDialog("Subiendo Imagen: paso 2 de 2...", 3);
            final collection =
                FirebaseFirestore.instance.collection(this.collection);
            await collection.add({
              'imgname': timestamp.toString() + ".jpg",
              'devid': identifier,
              'timestamp': timestamp,
              'name': (this.userName == null) ? "Anónimo" : this.userName,
            });

            code = 1;
          } catch (e) {
            print(e);
          }
          await pd.dismissProgressDialog();
          String message = (code == 1)
              ? "Imagen fue compartida exitosamente"
              : "Ocurrió un error, intenta otra vez";
          DialogTemplate.showMessage(context, message, "Aviso");
        },
        color: Color(this.colors[2]),
        textColor: Color(this.colors[3]),
        child: Text(
          "Compartir",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _showPhoto(bool showGray) {
    if (this.aiMode == 1) {
      return (this.showCapturedPhoto)
          ? Image.file(File(this.imageFile.path))
          : Container();
    } else {
      return (showGray)
          ? ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              child: (this.showCapturedPhoto)
                  ? Image.file(File(this.imageFile.path))
                  : Container(),
            )
          : (this.showCapturedPhoto)
              ? Image.file(File(this.imageFile.path))
              : Container();
    }
  }

  Widget _buildImageEditor() {
    return new Form(
      child: new ListView(
        //physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          ContainerTemplate.buildContainer(
              new Column(
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(bottom: 10, top: 5),
                    child: new Text(
                      "Tomar una Foto",
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  this._buidTakePictureButton(),
                  Visibility(
                    visible: this.showCapturedPhoto,
                    child: new Container(
                      padding: new EdgeInsets.all(5),
                      child: this._showPhoto(true),
                    ),
                  ),
                  Visibility(
                    visible: this.showCapturedPhoto && this.aiMode == 2,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        "Foto Original",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: this.showCapturedPhoto && this.aiMode == 2,
                    child: new Container(
                      padding: new EdgeInsets.all(5),
                      child: this._showPhoto(false),
                    ),
                  ),
                  Visibility(
                    visible: this.showCapturedPhoto,
                    child: this._editorButton(),
                  ),
                  Visibility(
                    visible: this.showFetchPhoto,
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      child: (this.showAlteredPhoto)
                          ? Image.file(File(this.imageAltered.path))
                          : this._buildFetchButton(),
                    ),
                  ),
                  Visibility(
                    visible: this.showAlteredPhoto,
                    child: this._buildUploadButton(),
                  ),
                ],
              ),
              [20, 20, 20, 40],
              15,
              10,
              10,
              0.15,
              30),
        ],
      ),
      key: this._formKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return this._buildImageEditor();
  }
}
