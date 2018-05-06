import 'package:flutter/material.dart';
import 'package:bibliotech/models/book.dart';
import 'package:bibliotech/components/text.dart';

// This StatefulWidget is meant to be an embedded view of the library's page
// for a specific book in the library, allowing the user to view the contents
// of the library database (for things like stock, reservations, and so forth).
class StockPanel extends StatelessWidget {
  const StockPanel(this.book);

  // The book to display the panel for
  final Book book;

  // This method is called when the StockPanel is being rendered. This builds a
  // quick summary of the information the library has, showing the number of
  // copies that are available, the Dewey Decimal number on file, and the people
  // who reserved it (if any).
  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(12.0),
      alignment: AlignmentDirectional.topStart,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text("Available", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
          // Puts the number left in stock in a bubble/greyed circle.
          new Center(
            child: new CircleAvatar(
              child: new Text(
                book.numLeft.toString()
              ),
            )
          ),
          new Text("Dewey Decimal", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
          new Center(
            child: new Text(book.dewey),
          ),
          new Text("Reserved by", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
          // Creates a horizontal list of the people who reserved it and specifies that
          // the same spacing should be used for each person's name. The names are shown
          // within a small bubble, and if nobody reserved it we simply show a N/A bubble.
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: (
              book.reservedBy.length != 0
              ? book.reservedBy.map<Widget>(
              (patron) => new TextBubble(patron, color: Colors.grey[200],)
            ).toList()
            : [
              new TextBubble("N/A", color: Colors.grey[200],)
            ])
          )
        ],
      ),
    );
  }
}