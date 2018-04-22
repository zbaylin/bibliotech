import 'dart:async';

import 'package:bibliotech/routes/books.dart';
import 'package:bibliotech/models/book.dart';
import 'package:bibliotech/pages/bookInfo.dart';


import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<Scan> {
  String barcode = "";
  Book book;

  @override
  initState() {
    super.initState();
    scan();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Barcode Scanner'),
          ),
          body: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  child: new RaisedButton(
                      onPressed: scan, child: new Text("SCAN")),
                  padding: const EdgeInsets.all(8.0),
                ),
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Text(barcode),
                ),
              ],
            ),
          )),
    );

  }

  Future scan() async {
    try {
      this.barcode = await BarcodeScanner.scan();
      this.book = await getBook(barcode);
      BookInfo bookInfo = BookInfo(book);
      Navigator.of(context).push(new MaterialPageRoute(builder: (context) => bookInfo));
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this.barcode = 'Please press scan or back');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}