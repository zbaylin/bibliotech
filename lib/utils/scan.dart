import 'dart:async';

import 'package:bibliotech/routes/books.dart';
import 'package:bibliotech/pages/bookInfo.dart';
import 'package:bibliotech/utils/feedback.dart';
import 'package:bibliotech/config.dart' as config;
import 'package:bibliotech/models/book.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future scan(BuildContext context) async {
  var book, barcode;
  try {
    barcode = await BarcodeScanner.scan();
    book = await getBook(barcode);
    if (book==null) {
      Map googlebook = await getFromGoogleBooksByISBN(barcode);      
      Map apiResponse = googlebook['items'][0];
      var title = googlebook['items'][0]['volumeInfo']['title'];
      showErrorDialog(context,"The book \"$title\" is not in the ${config.schoolName} library.");
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