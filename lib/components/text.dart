import 'package:flutter/material.dart';

class TextBubble extends StatelessWidget {

  TextBubble(this.text, {this.color});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Text(text),
      // Creates the background
      padding: EdgeInsets.all(6.0),
      decoration: new BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40.0)
      ),
    );
  }
}