import 'dart:convert';
import 'utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'utilities.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart';
import 'dart:io';

class DetailScreen extends StatefulWidget {
  final Coin c;

  const DetailScreen({Key key, this.c}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DetailScreenState(c: c);
}

class DetailScreenState extends State<DetailScreen> {
  final Coin c;
  CoinHistory history;
  double change;

  DetailScreenState({Key key, this.c});

  dynamic processData(data) {
    data = data['data'];
    if (data['change'] is int) {
      data['change'] = data['change'].toDouble();
      print('int');
    }
    history = CoinHistory(data['change'], data['history']);
    return history;
  }

  Future<List<Series<MyRow, DateTime>>> getHistoricalData() async {
    print("called");

    var response = await http.get(
        Uri.encodeFull(
            'https://api.coinranking.com/v1/public/coin/${c.index}/history/24h'),
        headers: {'accept': 'application/json'});

    var jsonData = jsonDecode(response.body);
    jsonData = processData(
        jsonData); //jsonData becomes a CoinHistory object (I know bad name but whatever)
    print(jsonData);

    change = jsonData.change;
    List<Series<MyRow, DateTime>> chartData =
        createChartData(jsonData.priceTime, change);

    return chartData;

    //print(response.toString());
  }

  @override
  Widget build(BuildContext context) {

    return Hero(
      tag: c.name,
      transitionOnUserGestures: false,
      child: Scaffold(
        
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: Column(
          
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          
          
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                c.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 5),
              child: Material(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                color: Colors.black,
                child: Padding(
                  padding: EdgeInsets.all(3),
                  child: Text(
                    c.symbol,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            FutureBuilder(
              future: getHistoricalData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  print(snapshot.connectionState);
                  print(snapshot.data);
                  if (snapshot.hasError) {
                    print(snapshot.error);
                  }
                  return Center(child: CircularProgressIndicator());
                } else {
                  //sleep(Duration(milliseconds: 500));
                  return Container(
                    height: 300,
                    margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: TimeSeriesChart(
                      snapshot.data,
                      animate: false,
                      animationDuration: Duration(milliseconds: 1000),
                      primaryMeasureAxis: NumericAxisSpec(
                        tickProviderSpec: BasicNumericTickProviderSpec(
                            zeroBound: false, dataIsInWholeNumbers: false),
                      renderSpec: NoneRenderSpec()
                      ),
                    ),
                  );
                }
              },
            )
            /*
            Container(
              height: 200,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TimeSeriesChart(
                  createSampleData(),
                  animate: true,
                ),
              ),
            )
            */
          ],
        ),
      ),
    );
  }
}
