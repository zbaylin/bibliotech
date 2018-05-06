import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bibliotech/models/book.dart';
import 'package:bibliotech/config.dart' as config;
import 'package:bibliotech/pages/bookInfo.dart';

// BookItem represents the preview you see of a book while scrolling through
// your shelf or the library view. For books in the library, we want to display
// a number of copies left in stock but for the books on your shelf that
// wouldn't make sense. In order to reuse code more efficiently, we have a type
// variable stored in the BookItem telling it whether to display the amount
// that's left in stock. The BookItemType is just a fancy way of storing the
// type of BookItem to display.
enum BookItemType {
  ON_SHELF,  // On my shelf (checked out)
  IN_LIBRARY // In the library (not checked out)
}

// As stated above, this object is a widget that gets displayed when scrolling
// through a list of book (either in your shelf or in the library as a whole).
class BookItem extends StatelessWidget {
  BookItem(this.book, this.type);

  // Stores the Book object, which contains info like ISBN number, title, etc.
  final Book book;
  // Stores the type of BookItem that this is
  final BookItemType type;

  // Default callback for when this widget is rendered, creating a card-based
  // interface in the Material Design style. This displays the book's cover
  // image (if one exists), the title, the author, and either the due date or
  // the number that are left in stock, based on the BookItemType. This also
  // performs some basic styling to make sure that the cards are all in a
  // consistent size, that the title is bolded, etc.
  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Container(
          child: new FlatButton(
            padding: EdgeInsets.all(0.0),
            child: new Column(
              children: <Widget>[
                // This pulls the cover image of the book from the library
                // server asynchronously. If it is still loading, we display
                // a circular progress bar, and if it is not found on the
                // server, then we display a generic placeholder icon.
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
                      // Selects the last line of the card based on the BookItemType
                      (this.type == BookItemType.ON_SHELF
                      ? new Text("Due ${book.dueDate}")
                      : new Text("${book.numLeft} left in stock"))
                    ],
                  ),
                )
              ]
          ),
          // When somebody clicks on the BookItem, it sends them to the BookInfo page of that Book.
          onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new BookInfo(book)))
        ),
      )
    );
  }
}