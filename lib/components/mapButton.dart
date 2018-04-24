import 'package:flutter/material.dart';

class MapButton extends StatelessWidget {

  const MapButton({
    this.onPressed,
    this.title,
    this.image,
    this.active,
    this.color,
    this.message
  });

  final VoidCallback onPressed;
  final bool active;
  final ImageProvider image;
  final String title;
  final String message;
  final Color color;

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
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) =>  new AlertDialog(
              title: new Text(title),
              content: new Text(message.toString()),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("OK"),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          );
        },
        child: new Text(title),
      )
    );
  }
}