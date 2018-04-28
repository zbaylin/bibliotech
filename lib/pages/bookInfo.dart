import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share/share.dart';
import 'package:local_notifications/local_notifications.dart';
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

  @override
  void initState() {
    super.initState();
    book = widget.book;
  }

  remindMeBeforeDue() {
    // This will remind the patron n-1 days after they checkout the book to return it
    new Future.delayed(new Duration(seconds: config.checkoutDuration-1), () async {
      // Fix for Android 8.0+ which requires all new notifications to be sent through a channel
      final channel = const AndroidNotificationChannel(
        id: 'check_in_notification',
        name: 'Default',
        description: 'Grant this app the ability to remind ',
      );
      await LocalNotifications.createAndroidNotificationChannel(channel:  channel);
      LocalNotifications.createNotification(
        title: "${book.title} is due soon!",
        content: "If it has not been already, ${book.title} must be returned within 24 hours, or by ${DateTime.now().add(new Duration(days: 5))}",
        id: 0,
        onNotificationClick: new NotificationAction(
          actionText: "DISMISS",
          callback: handleNotificationAction,
          payload: "DISMISS"
        ),
        actions: [
          new NotificationAction(
            actionText: "RETURN",
            callback: handleNotificationAction,
            payload: "RETURN",
            launchesApp: false
          )
        ],
        androidSettings: new AndroidSettings(
          channel: channel,
        )
      );
    });
  }

  handleNotificationAction(String action) {
    switch (action) {
      case "RETURN":
        checkIn(book);
        LocalNotifications.removeNotification(0);
        break;
      default:
        LocalNotifications.removeNotification(0);
    }
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
                fit: BoxFit.cover
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
                          // If it has finished (meaning it has acquired the bool), 
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