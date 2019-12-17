import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'utilities.dart';
import 'CardItem.dart';
import 'newspage.dart';

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScrollController _scrollViewController;

  @override
  void initState() {
    super.initState();
    //Initialize scrolll controller when the widget is built
    _scrollViewController = ScrollController();
  }

  @override
  void dispose() {
    //Dispose the scroll controller to avoid memory leaks
    _scrollViewController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    StatsPage(),
    NewsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
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
                      ),
                      Tab(
                        text: "News",
                      )
                    ],
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

  static Widget _globalStatsBuilder(
      BuildContext context, AsyncSnapshot snapshot) {
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
  }

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      collapseMode: CollapseMode.parallax,
      centerTitle: true,
      background: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
              future: _getMarketInfo(),
              builder: (BuildContext context, AsyncSnapshot snapshot) =>
                  _globalStatsBuilder(context, snapshot))
        ],
      ),
    );
  }
}

class StatsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  static List<dynamic> _coins;
  static Map<String, dynamic> data;

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

  static Widget _statsPageBuilder(
      BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.data == null) {
      return Container(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ListView.builder(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) =>
          CardItem(c: snapshot.data[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
        future: _getCoinData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) =>
            _statsPageBuilder(context, snapshot));
  }
}
