import 'package:flutter/material.dart';

class LibraryMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new FlatButton(
        child: new Image.asset('assets/logo.png'),
        color: Colors.grey,
        onPressed: () => null,
      ),
    );
  }
}