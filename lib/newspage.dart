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

    _news = newsData;
    return _news;
  }

  AsyncSnapshot _capture = null;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    double cardHeight = 400; //vertical dimension of card

    return FutureBuilder(
      future: _getNewsData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //if (_capture == null) {
        if (snapshot.data == null) {
          print(snapshot.connectionState);
          //print(snapshot.data);
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          return Container(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        //}

        _capture =
            snapshot; //store the snapshot so that future is not called every time state is built

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (BuildContext context, int index) => Material(
            borderRadius: BorderRadius.circular(10.0),
            elevation: 0.0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 25),
              child: Container(
                height: cardHeight,
                //width: width - 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  // the box shawdow property allows for fine tuning as aposed to shadowColor
                  image: DecorationImage(
                      image: NetworkImage(snapshot.data[index].urlToImage),
                      alignment: Alignment.topCenter,
                      fit: BoxFit.fitHeight),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        // offset, the X,Y coordinates to offset the shadow
                        offset: Offset(0.0, 10.0),
                        // blurRadius, the higher the number the more smeared look
                        blurRadius: 10.0,
                        spreadRadius: 1.0)
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //Spacer(),
                    Container(
                      height: cardHeight / 3,
                      //width: ,
                      //constraints: BoxConstraints.expand(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Text(
                              snapshot.data[index].title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black]),
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      height: cardHeight / 4,
                      //width: width - 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        //borderRadius: BorderRadius.circular(10)

                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                            child: Text(
                              "Author: " +
                                  snapshot.data[index].author.split(" ")[0] +
                                  " " +
                                  snapshot.data[index].author.split(" ")[1],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                //fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
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
