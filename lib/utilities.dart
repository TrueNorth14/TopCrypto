import 'package:flutter/material.dart';

class DimensionHolder{
 double height;
 double width;

  DimensionHolder(this.height, this.width);
}

class Coin {
  final int index;
  final String symbol;
  final String name;
  final String color;
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
        this.color;
  }
}

int getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
}

List<double> convertListDouble(List<dynamic> original){
  List<double> newList = List(original.length);

  for(int i = 0; i<original.length; i++){
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
