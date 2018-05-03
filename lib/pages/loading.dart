import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:bibliotech/config.dart' as config;
import 'package:bibliotech/pages/mainNav.dart';
import 'package:bibliotech/pages/login.dart';

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
    determineNext();
  }


  // Determines the next page to go to based on the state of the config file
  determineNext() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();

    try {
      new File("${appDocDir.path}/config.json");
      await cacheConfig();
      Navigator.pushReplacement(context, new MaterialPageRoute(builder:(context) => new MainNav()));
    } catch (e) {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (builder) => new LogInPage()));
    }
  }

  // This stores all the config fields in memory
  // Faster than reading in the JSON config file each time
  cacheConfig() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File configFile = new File("${appDocDir.path}/config.json");
    Map json = JSON.decode(await configFile.readAsString());
    config.schoolName = json['school_name'];
    config.hostname = json['hostname'];
    config.username = json['username'];
    config.checkoutDuration = json['checkout_duration'];
    config.twitter = {'consumer_key': json['twitter']['consumer_key'],
                      'consumer_secret': json['twitter']['consumer_secret'],
                      'access_key': json['twitter']['access_key'],
                      'access_secret': json['twitter']['access_secret']};
  }

  @override
  Widget build(BuildContext context) {
    // Implement a spinning progress bar to keep the user's attention
    return new Container(
      color: Colors.white,
      child: new Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }

}