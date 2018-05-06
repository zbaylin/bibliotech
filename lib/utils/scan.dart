import 'dart:async';

import 'package:bibliotech/routes/books.dart';
import 'package:bibliotech/pages/bookInfo.dart';
import 'package:bibliotech/utils/feedback.dart';
import 'package:bibliotech/routes/bugs.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future scan(BuildContext context) async {
  var book, barcode;
  try {
    barcode = await BarcodeScanner.scan();
    book = await getBook(barcode);
    if (book == null) {
      showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          content: new Text("The book with ISBN $barcode cannot be found. You can request it from your media specialist."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("REQUEST"),
              onPressed: () { submitBugReport("Please try to get book with ISBN $barcode in your library."); Navigator.of(context).pop();},
            ),
            new FlatButton(
              child: new Text("CANCEL"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    } else {
      BookInfo bookInfo = BookInfo(book);
      Navigator.of(context).push(new MaterialPageRoute(builder: (context) => bookInfo));
    }
    
  } on PlatformException catch (e) {
    if (e.code == BarcodeScanner.CameraAccessDenied) {
      showErrorDialog(context, "Please grant Bibliotech camera permissions.");
    } else {
      showErrorDialog(context, "Unknown error: $e");
    }
  } on FormatException{
    showErrorDialog(context, "Please scan a barcode.");
  } catch (e) {
    showErrorDialog(context, "Unknown error: $e");
  }
}