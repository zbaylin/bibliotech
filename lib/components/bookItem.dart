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
    return new SizedBox(
      width: MediaQuery.of(context).size.width/2,
      height: 500.0,
      child: new Container(
          child: new FlatButton(
            child: new Column(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: new Container(
                    child: new CachedNetworkImage(
                      imageUrl: "${config.hostname}/img/${book.isbn}",
                      height: MediaQuery.of(context).size.height/7,
                      placeholder: new CircularProgressIndicator()
                    ),
                    decoration: new BoxDecoration(
                      boxShadow: [
                        new BoxShadow(blurRadius: 4.0, spreadRadius: 1.0)
                      ]
                    )
                  )
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
                  child: new Text(book.title, maxLines: 2, textAlign: TextAlign.center, style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))
                ),
                new Text(book.author, maxLines: 1)
              ] + (this.type == BookItemType.IN_LIBRARY
                ? [new Text("${book.numLeft.toString()} left in stock")]
                : [])
          ),
          onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new BookInfo(book)))
        ),
      )
    );
  }
}