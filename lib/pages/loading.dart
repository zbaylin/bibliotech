import 'package:flutter/material.dart';
import 'dart:io';
import "package:yaml/yaml.dart";
import 'package:flutter/services.dart' show rootBundle;
import 'package:bibliotech/config.dart' as config;
import 'package:bibliotech/pages/mainNav.dart';

class LoadingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new LoadingScreenState();
  }

}

class LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    cacheConfig();
  }

  // This stores all the config fields in memory
  // Allows for quick config references
  cacheConfig() async {
    String yamlString = await rootBundle.loadString('config.yaml');
    Map yaml = loadYaml(yamlString);
    config.schoolName = yaml['school_name'];
    config.hostname = yaml['hostname'];
    onDone();
  }

  // Once the caching is over, it switches the main widget to the Main Navigator
  onDone() async {
    Navigator.pushReplacement(context, new MaterialPageRoute(builder:(context) => new MainNav()));
  }

  @override
  Widget build(BuildContext context) {

    return new Container(
      color: Colors.white,
      child: new Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }

}