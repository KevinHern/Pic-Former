// Basic Imports
import 'package:flutter/material.dart';

// Routes
import 'package:time_shifter/screens/image_editor.dart';
import 'package:time_shifter/screens/view_work.dart';

// Templates
import 'package:time_shifter/templates/container_template.dart';
import 'package:time_shifter/templates/navbar_template.dart';
import 'package:time_shifter/templates/fade_template.dart';
import 'package:time_shifter/templates/dialog_template.dart';

// Models
import 'package:time_shifter/models/navbar.dart';

// Backend
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  bool isActive, landedWidget = false;
  //Option option;
  NavBar navBar;
  FadeAnimation _fadeAnimation;
  final List<int> colors = [0, 0, 0, 0];
  /*
    Primary Color
    Primary Color Light
    Primary Color Dark
    Text Color
  */

  @override
  void initState(){
    super.initState();
    navBar = new NavBar(1, 1);
    this._fadeAnimation = new FadeAnimation(this);
    this.colors[0] = 0xFF03a9f4;
    this.colors[1] = 0xFF67daff;
    this.colors[2] = 0xFF007ac1;
    this.colors[3] = 0xFF000000;
  }

  MainScreenState({Key key, @required this.isActive});

  Widget defaultScreen() {
    return new Center(
      child: ContainerTemplate.buildContainer(
        new Padding(
            padding: new EdgeInsets.all(10),
            child: new SingleChildScrollView(
              child: new Column(
                children: <Widget>[
                  new Text(
                    "AI Picture\nTransformer",
                    style: new TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(bottom: 5, top: 5),
                    child: new Divider(color: new Color(0x000000).withOpacity(0.15), thickness: 1,),
                  ),
                  new Text(
                    "Innovation Lab",
                    style: new TextStyle(fontSize: 18), textAlign: TextAlign.center,
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(bottom: 5, top: 5),
                    child: new Divider(color: new Color(0x000000).withOpacity(0.15), thickness: 1,),
                  ),
                  new Column(
                    children: <Widget>[
                      new Text(
                        "¡Bienvenido!\nEsta es una aplicación que te permite alterar las fotos de panoramas que tomes usando inteligencia artificial.\n"
                            + "La inteligencia artificial es capaz de alterar tus fotos para que se miren como si fueran de noche "
                            + "o incluso, puede convertir fotos en blanco y negro a color\n"
                            + "Además, puedes publicar tus fotos modificadas y puedes ver el trabajo de otras personas.\n¡Diviértete!",
                        style: new TextStyle(fontSize: 15),
                      ),
                      new GestureDetector(
                        onTap: () async {
                          const url = 'https://www.instagram.com/innovationlabug/';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            DialogTemplate.showMessage(context, "No se pudo abrir el navegador Browser, hubo un error.", "Aviso");
                          }
                        },
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              height: 35,
                              width: 35,
                              child: new Image.asset('assets/images/instagram.png'),
                            ),
                            new Text("@innovationlabug", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
        ),
        [30, 40, 30, 100], 25,
        15, 15, 0.15, 30,
      ),
    );
  }

  Widget aiScreen(){
    return new Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ContainerTemplate.buildTileOption(
            Icons.brightness_3_rounded,
            this.colors[2],
            "Nochenizar",
                () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ImageEditor(1)));
            },
          ),
          ContainerTemplate.buildTileOption(
            Icons.color_lens,
            this.colors[2],
            "Colorizar",
                () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ImageEditor(2)));
            },
          ),
        ],
      ),
    );
  }

  Widget workScreen(){
    return new Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ContainerTemplate.buildTileOption(
            Icons.brightness_3_rounded,
            this.colors[2],
            "Ver\nFotos",
                () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewWork(1)));
            },
          ),
          ContainerTemplate.buildTileOption(
            Icons.color_lens,
            this.colors[2],
            "Ver\nFotos",
                () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewWork(2)));
            },
          ),
        ],
      ),
    );
  }

  Widget returnScreen() {
    Widget toShow;
    switch(this.navBar.getPageIndex()) {
      case 0:
        toShow = this.workScreen();
        break;
      case 1:
        toShow = this.defaultScreen();
        break;
      case 2:
        toShow = this.aiScreen();
        break;
      default:
        toShow = Container();
        break;
    }
    return toShow;
  }

  void navOnTap(index){
    switch(index) {
      case 0:
        this.colors[0] = 0xFF03a9f4;
        this.colors[1] = 0xFF67daff;
        this.colors[2] = 0xFF007ac1;
        this.colors[3] = 0xFF000000;
        break;
      case 1:
        this.colors[0] = 0xFFff9800;
        this.colors[1] = 0xFFffc947;
        this.colors[2] = 0xFFc66900;
        this.colors[3] = 0xFF000000;
        break;
      case 2:
        this.colors[0] = 0xFF1a237e;
        this.colors[1] = 0xFF534bae;
        this.colors[2] = 0xFF000051;
        this.colors[3] = 0xFFFFFFFF;
        break;
      default:
        this.colors[0] = 0xFFff9800;
        this.colors[1] = 0xFFffc947;
        this.colors[2] = 0xFFc66900;
        this.colors[3] = 0xFF000000;
        break;
    }
    setState(() {

      this.navBar.setBoth(index);
    });
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
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
                  child: new Text('Advertencia'),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: new SingleChildScrollView(
              child: new Text('¿Estás seguro que quieres salir?'),
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: new Container(
                  height: 30,
                  width: 30,
                  child: Image.asset('assets/images/confirm.png'),
                ),
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: new Container(
                  height: 30,
                  width: 30,
                  child: Image.asset('assets/images/cancel.png'),
                ),
              ),
            ],
          );
        }
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: NavBarTemplate.buildBottomNavBar(
        this.navBar,
        NavBarTemplate.buildTripletItems([Icons.collections, Icons.image], ["Collección", "Alterar"]),
        navOnTap,
        NavBarTemplate.buildFAB(
          Icons.home,
          () {
            setState(() {
              this.colors[0] = 0xFFff9800;
              this.colors[1] = 0xFFffc947;
              this.colors[2] = 0xFFc66900;
              this.colors[3] = 0xFF000000;
              this.navBar.setBoth(1);
            });
          },
          "main_screen_fab",
          this.colors[2],
          Color(this.colors[3]).withOpacity(0.60)
        ),
        this._fadeAnimation.fadeNow(this.returnScreen()),
        this.colors[0],
        Color(this.colors[3]).withOpacity(0.60),
        Color(this.colors[3]),
      ),
    );
  }
}