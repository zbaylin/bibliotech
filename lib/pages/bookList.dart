import 'package:flutter/material.dart';
import 'package:bibliotech/components/bookItem.dart';
import 'package:bibliotech/routes/books.dart';

class BookList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new BookListState();
  } 
}

class BookListState extends State<BookList> {
  // Take a list of books and transform it into a ListView
  // This transformation takes pairs of books, using their
  // parity (odd or even) to determine whether they should
  // go on the left side or right side of the screen
  Widget buildListOfBooks(List bookList) {
    int counter = 0;
    List widgetList = [];
    List rowList = [];
    bookList.map((book) {
      if (counter.isOdd) {
        rowList.add(new BookItem(book));
        widgetList.add(new Row(children: rowList));
        rowList.clear();
      } else {
        rowList.add(new BookItem(book));
      }
      counter = counter + 1;
    });
    return new ListView(
      children: widgetList
    );
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: getAllBooks(),
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
                      return new RefreshIndicator(
                        onRefresh: () {onRefresh(context);},
                        child: new GridView.count(
                          crossAxisCount: 2,
                          children: listSnapshot.data.map<Widget>(
                            (book) => new BookItem(book)
                          ).toList()
                        ),
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

  onRefresh(BuildContext context) async {
    setState(() {});
    Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("List refreshed"),));
  }
}