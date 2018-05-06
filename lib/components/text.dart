import 'package:flutter/material.dart';

// TextBubble is a simple widget that we can use
// in order to display a piece of text in a nice-
// looking colored bubble, bringing the user's
// attention to that text.
class TextBubble extends StatelessWidget {
  // Takes a piece of text to show and an optional
  // background color for the bubble.
  TextBubble(this.text, {this.color});

  // The background color of the bubble
  final Color color;
  // The piece of text inside the bubble
  final String text;

  // Called when rendering the TextBubble. Handles
  // the way it gets drawn (padding and borders).
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Text(text),
      // Creates the background
      padding: EdgeInsets.all(6.0),
      decoration: new BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40.0)
      )
    );
  }
}