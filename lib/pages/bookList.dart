import 'package:flutter/material.dart';
import 'package:bibliotech/components/bookItem.dart';
import 'package:bibliotech/routes/books.dart';

enum BookListType {
  SHELF,
  LIBRARY
}

class BookList extends StatefulWidget {
  BookList(this.listType);

  final BookListType listType;

  @override
  State<StatefulWidget> createState() {
    return new BookListState();
  } 
}

class BookListState extends State<BookList> {
  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: this.widget.listType == BookListType.LIBRARY
              ? getAllBooks()
              : getAllMyBooks(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
            return new Center(child: new CircularProgressIndicator());
            break;
          default:
            if (snapshot.hasError) {
              return new Text("Error!");
            } else {
              return new FutureBuilder(
                future: snapshot.data.toList(),
                builder: (context, listSnapshot) {
                  switch (listSnapshot.connectionState) {
                    case ConnectionState.done:
                      return new GridView.count(
                        crossAxisCount: 2,
                        children: listSnapshot.data.map<Widget>(
                          (book) => new BookItem(book, this.widget.listType == BookListType.LIBRARY ? BookItemType.IN_LIBRARY : BookItemType.ON_SHELF)
                        ).toList()
                      );
                    default:
                      return new Center(child: new CircularProgressIndicator());
                    }
                }
              );
            }
        }
      }
    );
  }
}