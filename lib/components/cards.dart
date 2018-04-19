import 'package:flutter/material.dart';

class TitledCard extends StatelessWidget {
  const TitledCard({Key key, this.child, this.title, this.mainAxisAlignment = MainAxisAlignment.center}) : super (key: key);

  final Widget child;
  final String title;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Column(
        mainAxisAlignment: mainAxisAlignment,
        children: <Widget>[
          new Container(
            alignment: AlignmentDirectional.centerStart,
            padding: new EdgeInsets.only(top: 10.0, left: 10.0),
            child: new Text(
              this.title,
              style: new TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w300
              ),
            ),
          ),
          this.child
        ],
      ),
    );
  }
}