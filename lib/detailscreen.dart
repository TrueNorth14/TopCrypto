import 'package:flutter/material.dart';
import 'utilities.dart';
import 'package:charts_flutter/flutter.dart';

class DetailScreen extends StatelessWidget {
  final Coin c;

  const DetailScreen({Key key, this.c}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Hero(
      tag: c.name,
      transitionOnUserGestures: true,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: InkWell(
            customBorder: CircleBorder(),
            onTap: () => Navigator.pop(context),
            splashColor: Colors.grey,
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: Column(
          children: <Widget>[
            
            Center(
              child: Text(c.name),
            ),
          ],
        ),
      ),
    );
  }
}
