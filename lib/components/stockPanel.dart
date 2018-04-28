import 'package:flutter/material.dart';
import 'package:bibliotech/models/book.dart';
import 'package:bibliotech/components/text.dart';

class StockPanel extends StatelessWidget {
  const StockPanel(this.book);

  final Book book;

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