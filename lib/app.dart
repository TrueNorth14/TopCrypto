import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'utilities.dart';
import 'CardItem.dart';
import 'newspage.dart';

//3 god bless em

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static int _pageNumber = 0;
  static final _titles = ["Coins", "News", "Alerts"];
  static List<dynamic> _coins;
  static Map<String, dynamic> data;
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
    super.initState();
    //_tabController = TabController(length: 3, vsync: this);
    _scrollViewController = ScrollController();
  }

  @override
  void dispose() {
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
    NewsPage(),
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
                  elevation: 10,
                  floating: true,
                  pinned: true,
                  //snap: true,
                  expandedHeight: MediaQuery.of(context).size.height / 3,
                  flexibleSpace: MyFlexibleSpace(),
                  backgroundColor: Colors.indigoAccent[700],
                  bottom: TabBar(
                    //controller: _tabController,
                    indicatorWeight: 4,
                    indicatorColor: Colors.white,
                    isScrollable: false,
                    tabs: <Widget>[
                      Tab(
                        text: "Stats",
                        //icon: Icon(Icons.show_chart),
                      ),
                      Tab(
                        text: "News",
                        //icon: Icon(Icons.library_books),
                      ),
                      Tab(
                        text: "Alerts",
                        //icon: Icon(Icons.add_alert),
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

class MyFlexibleSpace extends StatelessWidget {
  static Map<String, dynamic> data;

  Future<MarketInfo> _getMarketInfo() async {
    MarketInfo info;

    var response = await http.get(
        Uri.encodeFull('https://api.coinranking.com/v1/public/stats?base=USD'),
        headers: {'accept': 'application/json'});

    var responseToJson = jsonDecode(response.body);
    data = responseToJson['data'];
    info = MarketInfo(data['totalMarketCap'], data['total24hVolume']);

    return info;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlexibleSpaceBar(
      collapseMode: CollapseMode.parallax,
      centerTitle: true,
      background: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: _getMarketInfo(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Column(
                children: <Widget>[
                  Text(
                    "Total Market Cap: " +
                        ((snapshot.data != null)
                            ? snapshot.data.totalMarketCap.toString()
                            : "Loading..."),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    "24hr Market Volume: " +
                        ((snapshot.data != null)
                            ? snapshot.data.total24hVolume.toString()
                            : "Loading..."),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}

class MarketInfo {
  final double totalMarketCap;
  final double total24hVolume;

  MarketInfo(this.totalMarketCap, this.total24hVolume);

  bool hasData() => (total24hVolume != null && totalMarketCap != null);
}
