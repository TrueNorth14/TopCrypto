import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'main.dart';
import 'utilities.dart';
import 'CardItem.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

//3 god bless em

Map<String, dynamic> data;

//Map<String, String> _coinNames = {"Bitcoin": "BTC", "Ethereum": "ETH"};

class MyAppState extends State<MyApp> {
  static int _pageNumber = 0;
  static final _titles = ["Coins", "News", "Alerts"];
  static List<dynamic> _coins;
  
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

          return Stack(children: <Widget>[
            ClipPath(
              clipper: ClippingClass(),
              child: Container(
                // Add box decoration
                decoration: BoxDecoration(
                  // Box decoration takes a gradient
                  gradient: LinearGradient(
                    // Where the linear gradient begins and ends
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    // Add one stop for each color. Stops should increase from 0 to 1
                    //stops: [0.1, 0.9],
                    colors: [
                      // Colors are easy thanks to Flutter's Colors class.
                      Colors.purple,
                      Colors.blue
                    ],
                  ),
                ),
              ),
            ),
            Scrollbar(
              child: ListView.builder(
                //itemCount: _coins.length,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, 15, 0, 0),
                              child: Text(
                                "Coin Watch",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            )
                          ],
                        ),
                        CardItem(
                          c: snapshot.data[index],
                        )
                      ],
                    );
                  }
                  return CardItem(c: snapshot.data[index]);
                },
              ),
            )
          ]);
        }),
    Text("News Page"),
    Text("Alerts")
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
        body: _pages[0],
        /*
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
            ])
            */
      ),
    );
  }
}


