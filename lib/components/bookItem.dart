import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bibliotech/models/book.dart';
import 'package:bibliotech/config.dart' as config;
import 'package:bibliotech/pages/bookInfo.dart';

enum BookItemType {
  ON_SHELF,  // On my shelf (checked out)
  IN_LIBRARY // In the library (not checked out)
}

class BookItem extends StatelessWidget {
  BookItem(this.book, this.type);

  final Book book;
  final BookItemType type;

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Container(
          child: new FlatButton(
            padding: EdgeInsets.all(0.0),
            child: new Column(
              children: <Widget>[
                new CachedNetworkImage(
                  imageUrl: "${config.hostname}/img/${book.isbn}",
                  height: MediaQuery.of(context).size.height/3,
                  placeholder: new Container(
                    height: MediaQuery.of(context).size.height/3,
                    child: new Center(
                      child: new CircularProgressIndicator(),
                    )
                  ),
                  errorWidget: new Container(
                    height: MediaQuery.of(context).size.height/3,
                    child: new Icon(Icons.book, size: MediaQuery.of(context).size.height/4)
                  ),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                new Container (
                  decoration: new BoxDecoration(),
                  child: new Column(
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 2.0, left:6.0, right:6.0),
                        child: new Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))
                      ),
                      new Text(book.author, maxLines: 1),
                      (this.type == BookItemType.IN_LIBRARY
                      ? new Text("${book.numLeft.toString()} left in stock")
                      : new Container())
                    ],
                  ),
                )
              ]
          ),
          onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new BookInfo(book)))
        ),
      )
    );
  }
}