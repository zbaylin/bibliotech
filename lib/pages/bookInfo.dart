import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share/share.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/initialization_settings.dart';
import 'package:flutter_local_notifications/notification_details.dart';
import 'package:flutter_local_notifications/platform_specifics/android/initialization_settings_android.dart';
import 'package:flutter_local_notifications/platform_specifics/android/notification_details_android.dart';
import 'package:flutter_local_notifications/platform_specifics/ios/initialization_settings_ios.dart';
import 'package:flutter_local_notifications/platform_specifics/ios/notification_details_ios.dart';
import 'dart:math';
import 'package:bibliotech/models/book.dart';
import 'package:bibliotech/config.dart' as config;
import 'package:bibliotech/components/cards.dart';
import 'package:bibliotech/routes/books.dart';
import 'package:bibliotech/components/googleBooksPanel.dart';
import 'package:bibliotech/components/stockPanel.dart';
import 'package:bibliotech/components/twitterPanel.dart';
import 'package:bibliotech/pages/map.dart';


class BookInfo extends StatefulWidget {
  BookInfo(this.book);
  final Book book;

  @override
  State<StatefulWidget> createState() {
    return new BookInfoState();
  }
}

class BookInfoState extends State<BookInfo> {
  Book book;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  int notificationID;

  @override
  void initState() {
    super.initState();
    book = widget.book;

    // Creates an instance of the notification plugin
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    // Enables platform-specific code for Android
    InitializationSettingsAndroid initializationSettingsAndroid = new InitializationSettingsAndroid('notification_icon');
    // Enables platform-specific code for iOS
    InitializationSettingsIOS initializationSettingsIOS = new InitializationSettingsIOS();
    // Sets the options for the notifications
    InitializationSettings initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    // Initializes the plugin to display notifications
    flutterLocalNotificationsPlugin.initialize(initializationSettings, selectNotification: handleNotification);
    // Generates a random ID number for the notification
    notificationID = new Random().nextInt(100);
  }

  Future handleNotification(String payload) async {
    switch (payload) {
      // If the Payload is return, dismiss the notification and return the book.
      case "RETURN":
        flutterLocalNotificationsPlugin.cancel(notificationID);
        checkIn(book);
        break;
      // Else - dismiss the notification
      default:
        flutterLocalNotificationsPlugin.cancel(notificationID);
    }
  }

  remindMeBeforeDue() async {
    // Set the schedule date to be when the book is due
    var scheduledNotificationDateTime = new DateTime.now().add(new Duration(days: config.checkoutDuration));
    // Creates an Android Notification Channel (required for Android 8.0+)
    NotificationDetailsAndroid androidPlatformChannelSpecifics = new NotificationDetailsAndroid("DEFAULT", "Reminders", 'Reminds you when a book is overdue', importance: Importance.Max, priority: Priority.Max);
    // Enables the notification for iOS
    NotificationDetailsIOS iOSPlatformChannelSpecifics = new NotificationDetailsIOS();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    // Schedules the notification with the RETURN payload
    await flutterLocalNotificationsPlugin.schedule(
        notificationID,
        '${book.title} needs to be checked in soon!',
        "Tap here to check in ${book.title}",
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        payload: "RETURN");
  }

  @override
  Widget build(BuildContext context) {
    return new Builder(
      builder: (context) => new Scaffold(
        appBar: new AppBar(
          title: new Text(book.title)
        ),
        body: new Builder(
          builder: (context) =>
            new ListView(
            children: <Widget>[
              // Displays a fragment of the book cover
              new CachedNetworkImage(
                imageUrl: "${config.hostname}/img/${book.isbn}",
                width: 600.0,
                height: 300.0,
                fit: BoxFit.cover,
                errorWidget: new Container(
                  child: new Icon(Icons.book, size: 300.0,),
                  width: 600.0,
                  height: 300.0,
                ),
              ),
              // This will create a Row of Buttons
              new Padding(
                padding: EdgeInsets.all(8.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    // This is to determine whether or not the button is to check out or check in
                    new FutureBuilder(
                      // Runs a server side query to determine if the user has the book
                      future: doIHave(book),
                      // Takes a "snapshot" of the future
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          // Determines the current state of the snapshot, and checks it against various criteria
                          // If it isn't done yet (none, active, waiting), show a loading icon
                          case ConnectionState.none:
                          case ConnectionState.active:
                          case ConnectionState.waiting:
                            return new CircularProgressIndicator();
                            break;
                          // If it has finished (meaning it has acquired the boolean), 
                          default:
                            // Tests if the person has the book
                            // N.B. the data of the snapshot is a boolean
                            if (snapshot.data) {
                              return new FlatButton(
                                child: new Column(
                                  children: <Widget>[
                                    new Icon(Icons.call_received, color: Theme.of(context).primaryColor, size: 30.0,),
                                    new Text("Check In", style: new TextStyle(color: Theme.of(context).primaryColor))
                                  ],
                                ),
                                onPressed: () async {
                                  final response = await checkIn(book);
                                  Scaffold.of(context).showSnackBar(new SnackBar(
                                    content: new Text(response['message'])
                                  ));
                                  setState(() => null);
                                },
                              );
                            } else if (book.numLeft !=0){
                              return new FlatButton(
                                child: new Column(
                                  children: <Widget>[
                                    new Icon(Icons.call_made, color: Theme.of(context).primaryColor, size: 30.0,),
                                    new Text("Check Out", style: new TextStyle(color: Theme.of(context).primaryColor))
                                  ],
                                ),
                                onPressed: () async {
                                  final response = await checkOut(book);
                                  if (response['success']) {
                                    remindMeBeforeDue();
                                  }
                                  Scaffold.of(context).showSnackBar(new SnackBar(
                                    content: new Text(response['message'])
                                  ));
                                  setState(() => null);
                                }
                              );
                            } else {
                              return new FlatButton(
                                child: new Column(
                                  children: <Widget>[
                                    new Icon(Icons.recent_actors, color: Theme.of(context).primaryColor, size: 30.0,),
                                    new Text("Reserve", style: new TextStyle(color: Theme.of(context).primaryColor))
                                  ],
                                ),
                                onPressed: () async {
                                  final response = await reserve(book);
                                  Scaffold.of(context).showSnackBar(new SnackBar(
                                    content: new Text(response['message'])
                                  ));
                                  setState(() => null);
                                }
                              );
                            }
                        }
                      },
                    ),
                    new FlatButton(
                      child: new Column(
                        children: <Widget>[
                          new Icon(Icons.map, color: Theme.of(context).primaryColor, size: 30.0),
                          new Text("Find on Map", style: new TextStyle(color: Theme.of(context).primaryColor))
                        ],
                      ),
                      onPressed: () => Navigator.of(context).push(
                        new MaterialPageRoute(builder: (context) => 
                        new Scaffold(
                          appBar: new AppBar(title: new Text("Map: ${book.dewey}")),
                          body: LibraryMap(LibraryMapType.HIGHLIGHT, deweyDecimal: double.parse(book.dewey)),
                        )
                      )),
                    ),
                    new FlatButton(
                      child: new Column(
                        children: <Widget>[
                          new Icon(Icons.share, color: Theme.of(context).primaryColor, size: 30.0),
                          new Text("Share", style: new TextStyle(color: Theme.of(context).primaryColor))
                        ],
                      ),
                      onPressed: () => share("Check out ${book.title} by ${book.author} at ${config.schoolName}"),
                    )
                  ],
                ),
              ),
              new Divider(),
              new Text(book.title, textAlign: TextAlign.center, style: new TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
              new Text(book.author, textAlign: TextAlign.center, style: new TextStyle(fontSize: 18.0)),
              new TitledCard(
                title: "Info",
                child: new GoogleBooksPanel(book)
              ),
              new TitledCard(
                title: "Stock",
                child: new StockPanel(book),
              ),
              new TitledCard(
                title: "Twitter",
                child: new TwitterPanel(book),
              )
            ]
          )
        )
      )
    );
  }
}