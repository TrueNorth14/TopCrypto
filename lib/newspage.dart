import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/rendering.dart';
import 'config.dart';

class NewsPage extends StatelessWidget {
  static List<News> _news;

  static Future<List<News>> _getNewsData() async {
    List<News> newsData = [];
    String url =
        "https://newsapi.org/v2/everything?q=cryptocurrency&apiKey=$newsApiKey";

    var response = await http
        .get(Uri.encodeFull(url), headers: {'accept': 'application/json'});

    var responseToJson = jsonDecode(response.body);

    //print(responseToJson);

    //Map<String, dynamic> newsItems = responseToJson["data"];
    var articles = responseToJson["articles"];
    //print(articles);

    for (var article in articles) {
      if (article["content"] == null) {
        article["content"] = "Read the full article at...";
      }

      News n = News(
          article["author"],
          article["title"],
          article["description"],
          article["url"],
          article["urlToImage"],
          article["publishedAt"],
          article["content"]);

      //print(n);
      newsData.add(n);
    }

    print(newsData.length);

    for (var item in newsData) {
      String printed = item.toString() + " \n";
      print(printed);
    }
    _news = newsData;
    return _news;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
      future: _getNewsData(),
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
          itemBuilder: (BuildContext context, int index) => SizedBox(
            height: 230,
            child: Material(
              elevation: 20,
              child: Column(
                children: [
                  Container(
                    //height: 170,
                    child: Image.network(snapshot.data[index].urlToImage, fit: BoxFit.fill,),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    /*Center(
      child: RaisedButton(
        child: Text("data"),
        onPressed: () => getNewsData(),
      ),
    ); */
  }
}

//abc51b3de0f14f8482de2fe88e65c229

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
    return this.content;

    /*this.author +
        " " +
        this.title +
        " " +
        this.description +
        " " +
        this.url +
        " " +
        this.urlToImage +
        " " +
        this.publishedAt; +
        
        " " +
        this.content; */
  }
}
