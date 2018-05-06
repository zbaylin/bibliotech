import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bibliotech/models/book.dart';
import 'package:bibliotech/routes/books.dart';
import 'package:bibliotech/config.dart' as config;

// This StatefulWidget is meant to be an embedded view of the Twitter conversations
// about a specific book. It allows the user to preview a few tweets, write their
// own tweets, or go to a full view of the tweets that are previewed in their Twitter
// app or their browser.
class TwitterPanel extends StatefulWidget {
  // The book being discussed
  final Book book;

  TwitterPanel(this.book);

  // Sets up the TwitterPanel to be managed by a TwitterPannelState object
  @override
  TwitterPanelState createState() => new TwitterPanelState();
}

// The State of the TwitterPanel, managing the asynchronous loading process of the
// tweets and the user's interaction with Twitter through the panel.
class TwitterPanelState extends State<TwitterPanel> {
  // Called to render the TwitterPanel. Creates a layout with a short header at the top,
  // either a list of tweets or an error saying no tweets were found, and a TWEET button.
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
                    // Takes only the first five tweets so that we don't have to display a bunch.
                    children: (snapshot.data.isNotEmpty 
                    ? snapshot.data.take(5).map<Widget>((tweet) =>
                      new ListTile(
                        title: new Text(tweet['user']['screen_name']),
                        subtitle: new Text(tweet['text']),
                        // If the user taps the tweet, it goes to the Twitter link so that you can
                        // read the rest of the thread or reply to the author.
                        onTap: () => launch("https://twitter.com/i/web/status/${tweet['id_str']}")
                      )
                    ).toList()
                    // If no tweets were found, just show a quick error message explaining that.
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
                      // If the user clicks the TWEET buton, we write a template tweet for them and then open
                      // it in their twitter app to allow them to edit it before sending.
                      onPressed: () {
                        final String message = "Check out ${widget.book.title} by ${widget.book.author} at ${config.schoolName}!";
                        launch("https://twitter.com/intent/tweet?text=$message");
                      }
                    )
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

// This Widget gets displayed in place of the TwitterPanel in the event of an error finding
// the Twitter conversations for that book. Simply shows an error  message to let the user
// know what happened.
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