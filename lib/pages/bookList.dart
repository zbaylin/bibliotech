import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bibliotech/components/bookItem.dart';
import 'package:bibliotech/routes/books.dart';

// Since the same widget is being used for multiple display types, we have an Enumerated Type
// to change what elements are displayed, etc.
enum BookListType {
  SHELF,
  LIBRARY,
  SEARCH,
  DEWEY
}

class BookList extends StatefulWidget {
  BookList(this.listType, {this.searchTerm, this.deweyRange});

  // This is a required parameter, else the widget doesnt know what to display
  final BookListType listType;
  // Only required if listType == BookListType.SEARCH
  // Makes a network request to the server searching for books
  final String searchTerm;
  // Only required if listType == BookListType.DEWEY
  // Makes a network request to the server searching
  // for all books starting with deweyRange.
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
    // Takes a Future and will re-evaluate it every time it changes state.
    return new FutureBuilder(
      // Since there are multiple ListTypes, the widget needs a different Future for each type
      // (see setFuture()).
      future: setFuture(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          // If the widget is still waiting on the Stream, show a loading indicator
          case ConnectionState.active:
          case ConnectionState.waiting:
            return new Center(child: new CircularProgressIndicator());
            break;
          // When it's done, convert the stream to a list
          default:
            if (snapshot.hasError) {
              return new Text("Error!");
            } else {
              // Now this [FutureBuilder] will wait until the Stream is turned into a list
              return new FutureBuilder(
                future: snapshot.data.toList(),
                builder: (context, listSnapshot) {
                  switch (listSnapshot.connectionState) {
                    // If the list is available, then create the view
                    case ConnectionState.done:      
                      // Create a view that can be refreshed using the standard "pull to refresh" action
                      return new RefreshIndicator(
                        // When the user wants the list to refresh, run onRefresh().
                        // (see onRefresh())
                        onRefresh: () {onRefresh(context);},
                        // The main widget is an infinitely expandable [CustomScrollView]
                        // This is chosen to make the tiles not overflow on various screen sizes.
                        child: new CustomScrollView(
                          slivers: <Widget>[
                            new SliverGrid.count(
                              // Set the aspect ratio of the [BookItem] widgets to the aspect ratio of the screen
                              childAspectRatio: MediaQuery.of(context).size.width/MediaQuery.of(context).size.height,
                              // Dynamically set the number of [BookItem] widgets per row based on screen width
                              crossAxisCount: MediaQuery.of(context).size.width~/150,
                              children: 
                                // Builds a list of [BookItem] widgets from every Book object in the list
                                listSnapshot.data.map<Widget>(
                                (book) {
                                    // Determines the BookItemType based on the current BookListType
                                    return new BookItem(book, this.widget.listType != BookListType.SHELF ? BookItemType.IN_LIBRARY : BookItemType.ON_SHELF);
                                  }
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
    // Gives the user feedback once the list has been refreshed
    Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("List refreshed"),));
    // Setting state will cause the [FutureBuilder] to rebuild with a new Future
    // This essentially mimics a refresh of the list.
    setState(() => null);
  }

  // Convenience method that determines what the Future for the
  // [FutureBuilder] will be. This extracts a switch/case statement,
  // so we don't have to state it implicitly (makes for cleaner code).
  Future<Stream> setFuture() {
    // N.B. All of these methods can be found in routes/books.dart
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