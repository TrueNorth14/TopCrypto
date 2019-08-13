import 'package:flutter/semantics.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'main.dart';
import 'utilities.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

//3 god bless em

Map<String, dynamic> data;

//Map<String, String> _coinNames = {"Bitcoin": "BTC", "Ethereum": "ETH"};

class MyAppState extends State<MyApp> {
  static int _pageNumber = 0;
  static final _titles = ["Coins", "News", "Alerts"];
  static List<dynamic> _coins;
  static DimensionHolder dimensions = new DimensionHolder(100, 200);

  static Future<List<Coin>> _getCoinData() async {
    List<Coin> crypto = [];

    print("called");

    var response = await http.get(
        Uri.encodeFull('https://api.coinranking.com/v1/public/coins'),
        headers: {'accept': 'application/json'});

    var responseToJson = jsonDecode(response.body);
    data = responseToJson['data'];
    _coins = data['coins'];

    for (var coin in _coins) {
      if (coin["change"] is int) {
        coin["change"] = coin["change"].toDouble();
        print("worked");
      }

      coin["price"] = double.parse(coin["price"]);

      Coin c = new Coin(
          coin["id"],
          coin["symbol"],
          coin["name"],
          coin["color"],
          coin["iconUrl"],
          coin["price"],
          coin["change"],
          convertListDouble(coin["history"]));
      //print(c);

      if (c.color != null) {
        crypto.add(c);
      }
    }

    print(crypto.length);
    return crypto;
    //var allCoins = new DataHolder(coins);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dimensions.height = 230;
    dimensions.width = 400;
  }

  final List _pages = [
    FutureBuilder(
        future: _getCoinData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            print(snapshot.connectionState);
            print(snapshot.data);
            if (snapshot.hasError) {
              print(snapshot.error);
            }
            return Container(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Scrollbar(
            child: ListView.builder(
              //itemCount: _coins.length,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: snapshot.data.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return getCard(snapshot.data[index]);
              },
            ),
          );
        }),
    Text("News Page"),
    Text("Alerts")
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            _titles[_pageNumber],
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0,
        ),
        /*
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          title: Text(
            _titles[_pageNumber],
            style: TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        */
        body: _pages[_pageNumber],
        bottomNavigationBar: BottomNavigationBar(
            elevation: 30,
            currentIndex: _pageNumber,
            selectedItemColor: Colors.blue,
            onTap: (int index) {
              setState(() {
                _pageNumber = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.timeline),
                title: Text("Coins"),
                backgroundColor: Colors.blueAccent,
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.library_books),
                  title: Text("News"),
                  backgroundColor: Colors.blueAccent),
              BottomNavigationBarItem(
                  icon: Icon(Icons.announcement),
                  title: Text("Alerts"),
                  backgroundColor: Colors.blueAccent),
            ]),
      ),
    );
  }
}

Widget getCard(Coin c) {
  //String _shortHand = "unknown";

  return Padding(
    padding: EdgeInsets.all(5),
    child: GestureDetector(
      onTapDown: (TapDownDetails) {
        print("tapped");
      },
      onTap: () {
        //print("$coinData");
        print("pressed $c");
      },
      child: SizedBox(
        height: 230,
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          curve: Curves.elasticInOut,
          //height: MyAppState.dimensions.height,
          //width: MyAppState.dimensions.width,
          child: Card(
            elevation: 20,
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
                        backgroundColor: Color(getColorFromHex(c.color)),
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
                            color: (c.change > 0) ? Colors.green : Colors.red),
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
