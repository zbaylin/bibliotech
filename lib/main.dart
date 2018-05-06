import 'package:flutter/material.dart';
import 'package:bibliotech/pages/loading.dart';
import 'package:bibliotech/pages/login.dart';

// Tells the application what to do on startup. main() is invoked by the
// operating system when running the app. This in turn delegates the startup
// procedure to the MyApp widget as its own application.
void main() => runApp(new MyApp());

// Declares the top widget in the hierarchy, informing it to use Material Design
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Bibliotech',
      routes: {
        '/LogInPage': (BuildContext context) => new LogInPage()
      },
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ).
        primarySwatch: Colors.blueGrey,
      ),
      // Start at the loading screen while we wait for the main app to load in
      home: new LoadingScreen()
    );
  }
}