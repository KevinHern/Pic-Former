import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class DialogTemplate {
  static ProgressDialog progress;

  static void showMessage(BuildContext context, String message, String title){
    showDialog(
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
                  child: new Text(title),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: new SingleChildScrollView(
              child: new Text(message),
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
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
        }
    );
  }

  static Future showFinalMessage(BuildContext context, int iconOption) async {
    String iconPath;
    switch(iconOption){
    // Bad = ball_red.png
      case 0:
        iconPath = 'assets/images/ball_red.png';
        break;
    // Good = ball_green.png
      case 1:
        iconPath = 'assets/images/ball_green.png';
        break;
    // Info = star.png
      case 10:
        iconPath = 'assets/images/star.png';
        break;
    }
    await showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Container(
                  height: 40,
                  width: 40,
                  child: new Image.asset(iconPath),
                ),
                new Padding(
                  padding: new EdgeInsets.only(left: 15),
                  child: new Text('¡Gracias!'),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: new Column(
              children: <Widget>[
                Image.network('https://media.tenor.com/images/c803436a4d4cb119f2bf0177050289ad/tenor.gif'),
                new SingleChildScrollView(
                  child: new Text('Jo Jo Jo\n\n¡Gracias por toda tu ayuda amigo! Hasta pronto'),
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Container(
                  height: 30,
                  width: 30,
                  child: Image.asset('assets/images/snowflake_green.png'),
                ),
              ),
            ],
          );
        }
    );
  }

  static void initLoader(BuildContext context, String message) async {
    progress = new ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true,
    );
    progress.style(
        message: message,
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(new Color(0xFF146B3A)),
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    await progress.show();
  }

  static void terminateLoader() async {
    if(progress.isShowing() && progress != null) {
      await progress.hide().timeout(new Duration(milliseconds: 500));
    }
  }
}