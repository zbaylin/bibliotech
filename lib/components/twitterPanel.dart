import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bibliotech/models/book.dart';
import 'package:bibliotech/routes/books.dart';
import 'package:bibliotech/config.dart' as config;

class TwitterPanel extends StatefulWidget {
  final Book book;

  TwitterPanel(this.book);

  @override
  TwitterPanelState createState() => new TwitterPanelState();
}

class TwitterPanelState extends State<TwitterPanel> {
  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: getFromTwitter(widget.book),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          // Determines the current state of the snapshot, and checks it against various criteria
          // If it isn't done yet (none, active, waiting), show a loading icon
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return new CircularProgressIndicator();
            break;
          default:
            if (snapshot.hasError) {
              return new TwitterError();
            }
            try {
              return new Column(
                children: [
                  new Container(
                    child: new Text("Check out what others are saying", style: new TextStyle(fontStyle: FontStyle.italic)),
                  ),
                  new Column(
                    children: (snapshot.data.isNotEmpty 
                    ? snapshot.data.take(5).map<Widget>((tweet) =>
                      new ListTile(
                        title: new Text(tweet['user']['screen_name']),
                        subtitle: new Text(tweet['text']),
                        onTap: () => launch("https://twitter.com/i/web/status/${tweet['id_str']}"),
                      )
                    ).toList()
                    : [
                        new Text("Bummer.", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
                        new Text("No Tweets found. Be the first to say something!")
                      ])
                  ),
                  new Container(
                    alignment: AlignmentDirectional.centerEnd,
                    child: new FlatButton(
                      child: new Text(
                        "TWEET", style: new TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      onPressed: () {
                        final String message = "Check out ${widget.book.title} by ${widget.book.author} at ${config.schoolName}!";
                        launch("https://twitter.com/intent/tweet?text=$message");
                      },
                    ),
                  )
                ]
              );
            } catch (e) {
              return new TwitterError();
            }
        }
      }
    );
  }
}

class TwitterError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Text("Uh oh!", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
        new Text("We can't seem to contact Twitter right now.")
      ],
    );
  }
}