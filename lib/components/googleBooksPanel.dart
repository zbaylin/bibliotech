import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bibliotech/routes/books.dart';
import 'package:bibliotech/models/book.dart';
import 'dart:math';
import 'package:bibliotech/components/text.dart';

class GoogleBooksPanel extends StatefulWidget {

  GoogleBooksPanel(this.book);

  final Book book;

  @override
  GoogleBooksPanelState createState() => new GoogleBooksPanelState();
}

class GoogleBooksPanelState extends State<GoogleBooksPanel> {
  
  @override
  Widget build(BuildContext context) {
    // Waits until the data has been received from Google Books
    return new FutureBuilder(
      // Makes a request to Google Books using the Book object passed in from the host widget
      future: getFromGoogleBooks(widget.book),
      builder: (context, snapshot) {
        // Enumerates the states of the Future object
        switch (snapshot.connectionState) {
          // If it hasn't started (shouldn't happen) or is waiting, show a loading indicator
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Center(child: new CircularProgressIndicator());
            break;
          // If the request has been completed, show the information
          default:
            // Assigns the first result of the request to a new map
            Map apiResponse = snapshot.data['items'][0];
            return new Container(
              padding: EdgeInsets.all(12.0),
              alignment: AlignmentDirectional.topStart,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text("Rating",  textAlign: TextAlign.start, style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                  new Center(
                    child:
                    // Checks if the rating exists, if not, it will paint a circle with "N/A"
                    (apiResponse['volumeInfo']['averageRating'] == null
                    ? new CircleAvatar(child: Text("N/A"),)
                    : new CircleAvatar(
                      // Converts the Double (number) to a String and then displays it in a circle
                      child: new Text(apiResponse['volumeInfo']['averageRating'].toString()),
                      // Linearly extrapolates the Color data from red to Green based on Rating
                      backgroundColor: Color.lerp(Colors.red, Colors.green, pow(apiResponse['volumeInfo']['averageRating'], 2)/25,),
                      foregroundColor: Colors.white,
                    )),
                  ),
                  new Text("Description",  textAlign: TextAlign.start, style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                  (apiResponse['volumeInfo']['description'] == null
                  ? new Text("None found")
                  : new Text(apiResponse['volumeInfo']['description'], maxLines: 12, overflow: TextOverflow.ellipsis,)),
                  new Divider(),
                  new Text("Genre(s)",  textAlign: TextAlign.start, style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                  (apiResponse['volumeInfo']['categories'] == null
                  ? new Center(child: new TextBubble("N/A", color: Colors.grey[200],))
                  : new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: apiResponse['volumeInfo']['categories'].map<Widget>(
                      // Wraps the text in a grey "bubble"
                      (category) => new TextBubble(category, color: Colors.grey[200],)
                    ).toList(),
                  )),
                  new Container(
                    alignment: AlignmentDirectional.centerEnd,
                    child: new FlatButton(
                      child: new Text("MORE INFO", style: new TextStyle(color: Theme.of(context).primaryColor)),
                      //This will take the user to the Google Books page for the corresponding ISBN
                      onPressed: () => launch(apiResponse['volumeInfo']['infoLink']),
                    ),
                  )
                ],
              ),
            );
        }
      },
    );
  }
}

