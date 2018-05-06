import 'dart:async';

import 'package:bibliotech/routes/books.dart';
import 'package:bibliotech/pages/bookInfo.dart';
import 'package:bibliotech/utils/feedback.dart';
import 'package:bibliotech/routes/bugs.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Utility function to open a bar-scanner view for scanning books
// Since this isn't a Widget, we have a global function to call
Future scan(BuildContext context) async {
  // Declare variables to store the book and barcode we're gonna scan
  var book, barcode;
  try {
    // Attempt to scan using the BarcodeScanner library
    barcode = await BarcodeScanner.scan();
    // Attempt to find a book that matches the ISBN we got
    book = await getBook(barcode);
    // If everything worked right, but we couldn't find a book...
    if (book == null) {
      // Tell the user that it couldn't be found and allow them to
      // send a "bug report" to the library server in order to
      // request that the librarian update the stock. For example,
      // if the user finds "The Hobbit" in the library but it isn't
      // found in the database, the librarian probably forgot to
      // list it or used the wrong ISBN. As a result, this is a
      // "bug" in the setup of the library server.
      showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          content: new Text("The book with ISBN $barcode cannot be found. You can request it from your media specialist."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("CANCEL"),
              // If the user chose to cancel, we close the dialog
              onPressed: () => Navigator.of(context).pop(),
            ),
            new FlatButton(
              child: new Text("REQUEST"),
              onPressed: () {
                // If the user chose to report it, we can just
                // submit the report and close the dialog
                submitBugReport("Please try to get book with ISBN $barcode in your library.");
                Navigator.of(context).pop();
              }
            )
          ]
        )
      );
    // If the book was found...
    } else {
      // We load the BookInfo for it and switch to that page
      BookInfo bookInfo = BookInfo(book);
      Navigator.of(context).push(new MaterialPageRoute(builder: (context) => bookInfo));
    }
  // PlatformException is generally due to a missing camera or
  // the user denying access to their camera, so we need to
  // show them the error.
  } on PlatformException catch (e) {
    if (e.code == BarcodeScanner.CameraAccessDenied) {
      // Since we know about the access being denied, we
      // can give them a more user-friendly message in
      // that specific case.
      showErrorDialog(context, "Please grant Bibliotech camera permissions.");
    } else {
      showErrorDialog(context, "Unknown error: $e", e.toString());
    }
  // If the barcode can't be parsed, let the user know that it
  // probably wasn't the right thing that they were scanning.
  } on FormatException{
    showErrorDialog(context, "Please scan a barcode.");
  // If the error isn't recognized, we still want to let the user
  // know that something went wrong, so we print out the error for
  // them to report later.
  } catch (e) {
    showErrorDialog(context, "Unknown error: $e", e.toString());
  }
}