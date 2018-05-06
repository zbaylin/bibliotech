import 'package:flutter/material.dart';
import 'package:bibliotech/pages/bookList.dart';

// Since we wanted our map to be interactive (allowing the users to click on
// different sections of the library and view more information), this widget
// handles the interactivity component of each section of the library as
// displayed on the map.
class MapButton extends StatelessWidget {
  const MapButton({
    this.onPressed,
    this.title,
    this.image,
    this.active,
    this.color,
    this.message,
    this.startsWith
  });

  // Stores the callback function to be called when the user taps on this
  final VoidCallback onPressed;
  // Specifies whether this section should be colored in or faded. This is
  // useful when we want to direct the user's attention to one specific
  // section on the map (such as when they are looking for a book).
  final bool active;
  // The background image to be used when rendering, in our case always just
  // an outline of the section of the library.
  final ImageProvider image;
  // The title of the section of the library, to be based on the Dewey Decimal
  // categorization of library sections.
  final String title;
  // A more user-friendly blurb saying what can be found in that section with
  // some examples or different terms.
  final String message;
  // The color to highlight the section with to show that it's active. We make
  // each section a different color to make it easier to associate parts of the
  // library with specific genres.
  final Color color;
  // The first digit of the Dewey Decimal numbers that are contained in that
  // section. For example, if startsWith = 2, then this is the 200s section.
  final int startsWith;

  // The default callback for rendering the MapButton. This function builds the
  // user interface as a colored/uncolored image with text inside of it and the
  // ability to click on it to view more info.
  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: image
        ),
        color: (active
        ? color
        : Colors.grey[300])
      ),
      child: new FlatButton(
        // When the user clicks on the MapButton, we display a dialog with more
        // information about the section and the ability to preview a list of
        // books that are stored in that section.
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) =>  new AlertDialog(
              title: new Text(title),
              content: new Text(message.toString()),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("VIEW BOOKS"),
                  // When the user clicks on the "VIEW BOOKS" button, they will
                  // be taken to a page that contains the Dewey Decimal range at
                  // the top and the list of books stored in that section beneath.
                  onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (context) =>
                    new Scaffold(
                      appBar: new AppBar(
                        title: new Text("Dewey: ${startsWith}00"),
                      ),
                      body: new BookList(BookListType.DEWEY, deweyRange: startsWith)
                    )
                  ))
                ),
                // Allows the user to return back to the map if they wish, cancelling
                // the current dialog.
                new FlatButton(
                  child: new Text("OK"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
        child: new Text(title),
      )
    );
  }
}