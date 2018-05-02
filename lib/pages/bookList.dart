import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bibliotech/components/bookItem.dart';
import 'package:bibliotech/routes/books.dart';

enum BookListType {
  SHELF,
  LIBRARY,
  SEARCH,
  DEWEY
}

class BookList extends StatefulWidget {
  BookList(this.listType, {this.searchTerm, this.deweyRange});

  final BookListType listType;
  final String searchTerm;
  final int deweyRange;

  @override
  State<StatefulWidget> createState() {
    return new BookListState();
  } 
}

class BookListState extends State<BookList> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: setFuture(),
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
                        child: new CustomScrollView(
                          slivers: <Widget>[
                            new SliverGrid.count(
                              childAspectRatio: MediaQuery.of(context).size.width/MediaQuery.of(context).size.height,
                              crossAxisCount: MediaQuery.of(context).size.width~/150,
                              children: 
                                listSnapshot.data.map<Widget>(
                                (book) => new BookItem(book, this.widget.listType == BookListType.LIBRARY ? BookItemType.IN_LIBRARY : BookItemType.ON_SHELF)
                                ).toList()
                            )
                          ],
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
    Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("List refreshed"),));
  }

  Future<Stream> setFuture() {
    switch (widget.listType) {
      case BookListType.SEARCH:
        return searchAllBooks(widget.searchTerm);
        break;
      case BookListType.SHELF:
        return getAllMyBooks();
        break;
      case BookListType.DEWEY:
        return getBooksWithDewey(widget.deweyRange);
      default:
        return getAllBooks();
    }
  }
}