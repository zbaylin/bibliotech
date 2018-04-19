import 'package:flutter/material.dart';
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
                  new Text(apiResponse['volumeInfo']['description'], maxLines: 12, overflow: TextOverflow.ellipsis,),
                  new Divider(),
                ],
              ),
            );
        }
      },
    );
  }
}

