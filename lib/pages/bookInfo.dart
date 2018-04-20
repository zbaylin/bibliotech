import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share/share.dart';
import 'package:bibliotech/models/book.dart';
import 'package:bibliotech/config.dart' as config;
import 'package:bibliotech/components/cards.dart';
import 'package:bibliotech/routes/books.dart';
import 'package:bibliotech/components/googleBooksPanel.dart';


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
                                  final snackbarText = await checkIn(book);
                                  Scaffold.of(context).showSnackBar(new SnackBar(
                                    content: new Text(snackbarText)
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
                                  final snackbarText = await checkOut(book);
                                  Scaffold.of(context).showSnackBar(new SnackBar(
                                    content: new Text(snackbarText)
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
                                  final snackbarText = await reserve(book);
                                  Scaffold.of(context).showSnackBar(new SnackBar(
                                    content: new Text(snackbarText)
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
                      onPressed: () => print("Go to Map"),
                    ),
                    new FlatButton(
                      child: new Column(
                        children: <Widget>[
                          new Icon(Icons.share, color: Theme.of(context).primaryColor, size: 30.0),
                          new Text("Share", style: new TextStyle(color: Theme.of(context).primaryColor))
                        ],
                      ),
                      onPressed: () => share("Check out ${book.title} by ${book.author} at ${config.schoolName}"),
                    ),
                  ],
                ),
              ),
              new Divider(),
              new Text(book.title, textAlign: TextAlign.center, style: new TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
              new Text(book.author, textAlign: TextAlign.center, style: new TextStyle(fontSize: 18.0)),
              new TitledCard(
                title: "Info",
                child: new GoogleBooksPanel(book)
              )
            ]
          )
        )
      )
    );
  }
}