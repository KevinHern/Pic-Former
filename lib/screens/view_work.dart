// Basic
import 'package:flutter/material.dart';

// Templates
import 'package:time_shifter/templates/container_template.dart';
import 'package:time_shifter/templates/button_template.dart';
import 'package:time_shifter/templates/navbar_template.dart';

// Backend
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewWork extends StatelessWidget{
  final int aiMode;
  ViewWork(int serverType, {Key key}) : this.aiMode = serverType;

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildAppBar(
      context,
      const [0xFF007ac1, 0xFF67daff, 0xFF000000],
      (this.aiMode == 1)? 'Nochenizados' : "Colorizados",
      ViewScreen(this.aiMode),
    );
  }
}

class ViewScreen extends StatefulWidget{
  final int aiMode;
  ViewScreen(int aiMode, {Key key}) : this.aiMode = aiMode;

  ViewState createState() => ViewState(this.aiMode);
}

class ViewState extends State<ViewScreen>{
  final int aiMode;
  final String collection;
  ViewState(int aiMode, {Key key}) :
        this.aiMode = aiMode,
        this.collection = (aiMode == 1)? "nightirizer" : "colorized";
  int pageCount;
  final List<int> colors = [0xFF03a9f4, 0xFF67daff, 0xFF007ac1, 0xFF000000];

  @override
  void initState(){
    super.initState();
    this.pageCount = 0;
  }


  Widget _buildTile(DocumentSnapshot snapshot) {
    return FutureBuilder(
      future: FirebaseStorage.instance.ref().child(snapshot.get('devid') + "/"+ snapshot.get('imgname')).getDownloadURL(),
      builder: (context, url) {
        return ContainerTemplate.buildContainer(
          Column(
            children: <Widget>[
              Text(
                snapshot.get("name"),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                width: double.infinity,
                child: (!url.hasData)?
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )  :
                  Image.network(url.data,
                    fit: BoxFit.fill,
                    loadingBuilder:(BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return Container(
                        padding: EdgeInsets.all(15),
                        child: child,
                      );
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null ?
                          loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  ),
              ),
            ],
          ),
          [10,10,10,10],
          15,
          5, 5, 0.15, 30,
        );
      },
    );
  }

  Widget _showImages(){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1,
            color: Color(this.colors[1]).withOpacity(0.5),
            style: BorderStyle.solid
        ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      width: double.infinity,
      height: 500,
      // REPLACE THIS LISTVIEW WITH LISTVIEW BUILDER WHEN IMPLEMENTING BACKEND
      child: StreamBuilder(
        //stream: FirebaseFirestore.instance.collection("images").orderBy('timestamp', descending: false).startAt([2*this.pageCount]).limit(2).snapshots(),
        stream: FirebaseFirestore.instance.collection(this.collection).orderBy('timestamp', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)));
          } else {
            if (snapshot.data.docs.length > 0) {
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return this._buildTile(snapshot.data.docs[index]);
                },
              );
            }
            else {
              return AlertDialog(
                title: Text("Aviso"),
                content: Text("Nadie ha compartido sus imágenes.\n¡Sé el primero!"),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildButtons(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Prev Button
        Visibility(
          visible: this.pageCount == 0,
          child: ButtonTemplate.buildBasicButton(
            () {
              setState(() {
                print(this.pageCount);
                this.pageCount -= (this.pageCount > 0)? 1 : 0;
              });
            },
              this.colors[2], "Previos", this.colors[3]
          ),
        ),
        // Next Button
        ButtonTemplate.buildBasicButton(
            () {
              setState(() {
                print(this.pageCount);
                this.pageCount += 1;
              });
            },
            this.colors[2], "Siguientes", this.colors[3]
        ),
      ],
    );
  }

  Widget _showBigScreen(){
    return ListView(
      padding: EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 30),
      children: [
        // Buttons
        //this._buildButtons(),
        // 10 images: Author + Image
        this._showImages(),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return this._showBigScreen();
  }
}

