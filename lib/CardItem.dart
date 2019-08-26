import 'package:e_pal/detailscreen.dart';
import 'package:flutter/material.dart';
import 'utilities.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

class CardItem extends StatelessWidget {
  final Coin c;

  const CardItem({Key key, this.c}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          //print("$coinData");
          //print("pressed $c");
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return DetailScreen(c: c);
          }));
        },
        child: Hero(
          tag: c.name,
          child: Container(
            height: 230,
            child: Card(
              elevation: 30,
              borderOnForeground: true,
              //borderRadius: BorderRadius.circular(8),

              //margin: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(15, 15, 0, 5),
                    child: Row(
                      children: <Widget>[
                        Text(
                          c.name,
                          textScaleFactor: 1.5,
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                          child: Text(
                            "\$" +
                                ((c.price > 1)
                                    ? c.price
                                        .toStringAsFixed(2)
                                        .replaceAllMapped(reg, mathFunc)
                                    : c.price.toStringAsFixed(4)),
                            textScaleFactor: 1.5,
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 8, 0),
                        child: CircleAvatar(
                          backgroundColor: (c.color != "#000")
                              ? Color(getColorFromHex(c.color))
                              : Colors.purple,
                          radius: 8,
                        ),
                      ),
                      Text(
                        c.symbol,
                        style: TextStyle(fontWeight: FontWeight.w300),
                      ),
                      Spacer(),
                      (c.change > 0)
                          ? Icon(Icons.arrow_drop_up, color: Colors.green)
                          : Icon(Icons.arrow_drop_down, color: Colors.red),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                        child: Text(
                          c.change.toString() + "%",
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color:
                                  (c.change > 0) ? Colors.green : Colors.red),
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                  Sparkline(
                    fallbackHeight: 130,
                    data: c.history,
                    lineColor: (c.change > 0) ? Colors.green : Colors.red,
                    fillMode: FillMode.below,
                    fillGradient: (c.change > 0)
                        ? LinearGradient(
                            colors: [Colors.green[100], Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)
                        : LinearGradient(
                            colors: [Colors.red[100], Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
