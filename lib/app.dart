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
  //TabController _tabController;
  ScrollController _scrollViewController;

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

      if (c.color == null) {
        c.color = "#000000";
      }

      crypto.add(c);
    }

    print(crypto.length);
    return crypto;
    //var allCoins = new DataHolder(coins);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_tabController = TabController(length: 3, vsync: this);
    _scrollViewController = ScrollController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //_tabController.dispose();
    _scrollViewController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
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

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (BuildContext context, int index) =>
              CardItem(c: snapshot.data[index]),
        );
      },
    ),
    Text("News Page"),
    Text("Alerts")
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          //body: _pages[0],
          body: NestedScrollView(
            body: TabBarView(
              children: _pages,
            ),
            controller: _scrollViewController,
            headerSliverBuilder: (BuildContext context, bool boxIsScorlled) {
              return [
                SliverAppBar(
                  title: Text("Top Crypto"),
                  elevation: 0,
                  floating: true,
                  pinned: true,
                  expandedHeight: MediaQuery.of(context).size.height/3,
                  backgroundColor: Colors.indigoAccent[700],
                  bottom: TabBar(
                    //controller: _tabController,
                    indicatorWeight: 4,
                    indicatorColor: Colors.white,
                    isScrollable: false,
                    tabs: <Widget>[
                      Tab(
                        text: "Stats",
                        icon: Icon(Icons.show_chart
                            //Icons.account_balance_wallet,
                            ),
                      ),
                      Tab(
                        text: "News",
                        icon: Icon(
                          Icons.library_books,
                        ),
                      ),
                      Tab(
                        text: "Alerts",
                        icon: Icon(
                          Icons.add_alert,
                        ),
                      )
                    ],
                    //controller: TabController(length: 3, vsync: TickerProvider(),),
                  ),
                ),
              ];
            },
          ),
        ),
      ),
    );
  }
}
