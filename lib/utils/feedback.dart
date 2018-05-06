import 'package:bibliotech/routes/bugs.dart';
import 'package:flutter/material.dart';

// Utility function to show an error pop-up dialog to the user
// Simply takes a message and a BuildContext and creates the pop-up
showErrorDialog(BuildContext context, String message, [String errorMessage]) {
  // Show an alert dialog
  showDialog(
    context: context,
    builder: (context) => new AlertDialog(
      // Set the contents to the message
      content: new Text(message),
      actions: <Widget>[
        new FlatButton(
          child: new Text("OK"),
          // When the user presses OK, close the dialog
          onPressed: () => Navigator.of(context).pop()
        )
      // If there is an errorMessage, we can display a
      // "report" button in the actions, so we add that
      // to the actions list.
      ] + (errorMessage != null
          ? <Widget>[
            new FlatButton(
              child: new Text("REPORT"),
              // When the user presses REPORT, we send the
              // error to the library server as a bug report
              // and then close the dialog
              onPressed: () {
                submitBugReport(errorMessage);
                Navigator.of(context).pop();
              }
            )
          ]
          // If there isn't an errorMessage, we add nothing
          : <Widget>[]
      )
    )
  );
}