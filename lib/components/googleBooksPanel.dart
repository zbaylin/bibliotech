import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bibliotech/routes/books.dart';
import 'package:bibliotech/models/book.dart';

class GoogleBooksPanel extends StatefulWidget {

  GoogleBooksPanel(this.book);

  final Book book;

  @override
  GoogleBooksPanelState createState() => new GoogleBooksPanelState();
}

class GoogleBooksPanelState extends State<GoogleBooksPanel> {
  
  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: getFromGoogleBooks(widget.book),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Center(child: new CircularProgressIndicator());
            break;
          default:
            Map apiResponse = snapshot.data['items'][0];
            return new Container(
              padding: EdgeInsets.all(12.0),
              alignment: AlignmentDirectional.topStart,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Center(
                    child:
                    // Checks if the rating exists, if not, it will paint a circle with "N/A"
                    (apiResponse['volumeInfo']['averageRating'] == null
                    ? new CircleAvatar(child: Text("N/A"),)
                    : new CircleAvatar(
                      // Converts the Double (number) to a String and then displays it in a circle
                      child: new Text(apiResponse['volumeInfo']['averageRating'].toString()),
                      // Linearly extrapolates the Color data from red to Green based on Rating
                      backgroundColor: Color.lerp(Colors.red[900], Colors.green[300], (apiResponse['volumeInfo']['averageRating'])/5,),
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
                  ? new Center(child: new Container(
                      child: new Text("N/A"),
                      // Creates the background
                      padding: EdgeInsets.all(6.0),
                      decoration: new BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(40.0)
                      ),
                    ))
                  : new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: apiResponse['volumeInfo']['categories'].map<Widget>(
                      (category) => new Container(
                        child: new Text(category),
                        // Creates the background
                        padding: EdgeInsets.all(6.0),
                        decoration: new BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(40.0)
                        ),
                      )
                    ).toList(),
                  )),
                  new Container(
                    alignment: AlignmentDirectional.centerEnd,
                    child: new FlatButton(
                      child: new Text("MORE INFO", style: new TextStyle(color: Theme.of(context).primaryColor)),
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

