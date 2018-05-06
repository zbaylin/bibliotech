import 'package:flutter/material.dart';

// Convenience class to cut down on code reuse. TitledCard is a simple
// reusable interface that displays a Material Design card with a title
// at the top and some child widget.
class TitledCard extends StatelessWidget {
  const TitledCard({Key key, this.child, this.title, this.mainAxisAlignment = MainAxisAlignment.center}) : super (key: key);

  // The widget to display within the card
  final Widget child;
  // The title to display at the top of the card
  final String title;
  // Basic guide to tell where the title should be aligned
  final MainAxisAlignment mainAxisAlignment;

  // This method is the default callback when rendering the TitledCard.
  // It goes over how the TitledCard should be rendered, which is done
  // as one large Material Design card, a piece of text at the top, and
  // the child. Some styling is applied to make sure that the font is
  // clearly a title, the text is aligned correctly, and that everything
  // fits on the screen.
  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Column(
        mainAxisAlignment: mainAxisAlignment,
        children: <Widget>[
          new Container(
            alignment: AlignmentDirectional.centerStart,
            padding: new EdgeInsets.only(top: 10.0, left: 10.0),
            child: new Text(
              this.title,
              style: new TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w300
              ),
            ),
          ),
          this.child
        ],
      ),
    );
  }
}