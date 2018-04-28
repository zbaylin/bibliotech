import 'package:flutter/material.dart';

showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => new AlertDialog(
      content: new Text(message),
      actions: <Widget>[
        new FlatButton(
          child: new Text("OK"),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    ),
  );
}