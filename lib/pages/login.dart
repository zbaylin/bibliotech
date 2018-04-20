import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:bibliotech/config.dart' as config;
import 'package:bibliotech/pages/loading.dart';

class LogInPage extends StatefulWidget {
  @override
  LogInPageState createState() => new LogInPageState();
}

class LogInPageState extends State<LogInPage> {

  TextEditingController usernameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Bibliotech: Log In"),),
      body: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("assets/login-background.jpg"),
            fit: BoxFit.cover
          )
        ),
        child: Column(
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.all(20.0),
              child: new Image.asset('assets/logo-white.png'),
            ),
            new Padding(
              padding: const EdgeInsets.only(left:12.0, right: 12.0),
              child: new Text("Welcome to Bibliotech. Please choose a unique username to begin.", textAlign: TextAlign.center, style: new TextStyle(color: Colors.white, fontSize: 20.0),),
            ),
            new Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0),
              child: new TextField(
                controller: usernameController,
                decoration: new InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: new OutlineInputBorder(borderRadius: new BorderRadius.all(new Radius.circular(4.0))),
                  isDense: true
                ),
              )
            ),
            new Container(
              padding: EdgeInsets.all(10.0),
              alignment: AlignmentDirectional.centerEnd,
              child: new RaisedButton(
                child: new Text("SUBMIT"),
                color: Theme.of(context).primaryColor,
                onPressed: submitUsername,
              ),
            )
          ],
        ),
      )
    );
  }

  submitUsername() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String defaultConfig = await rootBundle.loadString('config.json');
    File configFile = await new File("${appDocDir.path}/config.json").create();
    Map newConfig = JSON.decode(defaultConfig);
    Map usernameField = new Map<String, String>.from({'username': usernameController.text}); 
    newConfig.addAll(usernameField);
    await configFile.writeAsString(JSON.encode(newConfig));
    Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => new LoadingScreen()));
  }
}