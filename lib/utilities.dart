import 'package:e_pal/detailscreen.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';


/* Utilities file contains Models and an assortment of miscellaneous functions.
 * 
 * IMPORTANT: This file does not and should not contain UI elements.
*/


/* Models */

class CoinHistory {
  final double change;
  final List priceTime;

  CoinHistory(this.change, this.priceTime);

  @override
  String toString() {
    return change.toString() + " " + priceTime.toString();
  }
}

class Coin {
  final int index;
  final String symbol;
  final String name;
  String color;
  final String iconUrl;
  final double price;
  final double change;
  final List<double> history;

  Coin(this.index, this.symbol, this.name, this.color, this.iconUrl, this.price,
      this.change, this.history);

  String toString() {
    return this.symbol +
        " " +
        this.name +
        " " +
        this.iconUrl +
        " " +
        this.price.toString() +
        " " +
        this.change.toString() +
        " " +
        this.history.toString() +
        " " +
        this.color +
        " " +
        this.index.toString();
  }
}

// Sample time series data type.
class MyRow {
  final DateTime timeStamp;
  final double cost;
  MyRow(this.timeStamp, this.cost);

  String toString() {
    return timeStamp.toString();
  }
}

class MarketInfo {
  final double totalMarketCap;
  final double total24hVolume;

  MarketInfo(this.totalMarketCap, this.total24hVolume);

  bool hasData() => (total24hVolume != null && totalMarketCap != null);
}

class News {
  final String author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String content;

  News(this.author, this.title, this.description, this.url, this.urlToImage,
      this.publishedAt, this.content);

  @override
  String toString() {
    return this.author +
        " " +
        this.title +
        " " +
        this.description +
        " " +
        this.url +
        " " +
        this.urlToImage +
        " " +
        this.publishedAt +
        " " +
        this.content;
  }
}




int getColorFromHex(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return int.parse(hexColor, radix: 16);
}

List<double> convertListDouble(List<dynamic> original) {
  List<double> newList = List(original.length);

  for (int i = 0; i < original.length; i++) {
    newList[i] = double.parse(original[i]);
  }

  return newList;
}

RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
Function mathFunc = (Match match) => '${match[1]},';

/*
String printCoins(List x) {
  String _coinStr;

  for (var _coin in MyAppState._coins) {
    _coinStr += _coin.toString();
  }

  return _coinStr;
}
*/

List<Series<MyRow, DateTime>> createChartData(List coinHistory, double change) {
  List<MyRow> data = [
    /*
      new MyRow(new DateTime(2017, 9, 25), 6),
      new MyRow(new DateTime(2017, 9, 26), 8),
      new MyRow(new DateTime(2017, 9, 27), 6),
      new MyRow(new DateTime(2017, 9, 28), 9),
      new MyRow(new DateTime(2017, 9, 29), 11),
      new MyRow(new DateTime(2017, 9, 30), 15),
      new MyRow(new DateTime(2017, 10, 01), 25),
      new MyRow(new DateTime(2017, 10, 02), 33),
      new MyRow(new DateTime(2017, 10, 03), 27),
      new MyRow(new DateTime(2017, 10, 04), 31),
      new MyRow(new DateTime(2017, 10, 05), 23),
      */
  ];

  for (var point in coinHistory) {
    //print(point["timestamp"]);
    data.add(new MyRow(DateTime.fromMillisecondsSinceEpoch(point["timestamp"]),
        double.parse(point["price"])));
  }

  //print(data[0]);
  return [
    new Series<MyRow, DateTime>(
      id: 'Cost',
      domainFn: (MyRow row, _) => row.timeStamp,
      measureFn: (MyRow row, _) => row.cost,
      colorFn: (MyRow row, _) => (change > 0)
          ? MaterialPalette.green.shadeDefault.darker
          : MaterialPalette.red.shadeDefault,
      data: data,
    )
  ];
}

