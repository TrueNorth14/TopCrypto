import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/rendering.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'utilities.dart';
import 'config.dart';

class NewsPage extends StatelessWidget {
  static List<News> _news;

  static Future<List<News>> _getNewsData() async {
    //In order to pervent a network call everytime the widget gets built, check if data is in _news.
    //This saves time and ensures that there are no memory leaks.
    if (_news != null) {
      print("bypass api call");
      return _news;
    }

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

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (BuildContext context, int index) => GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetails(snapshot.data[index]),
              ),
            ),
            child: Material(
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
                    /*
                    image: DecorationImage(
                        image: NetworkImage(snapshot.data[index].urlToImage),
                        alignment: Alignment.topCenter,
                        fit: BoxFit.fitHeight),
                    */
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
                  child: Stack(
                    //fit: StackFit.expand,
                    children: <Widget>[
                      Positioned.fill(
                        //alignment: Alignment.topCenter,
                        //height: cardHeight,
                        //fit: BoxFit.fitHeight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Hero(
                            tag: snapshot.data[index].author,
                            child: Image.network(
                              snapshot.data[index].urlToImage,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ),
                      Column(
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              //mainAxisSize: MainAxisSize.min,
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
                            height: cardHeight / 4.5,
                            //width: width - 30,
                            decoration: BoxDecoration(
                              color: Colors.black,
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
                                        snapshot.data[index].author
                                            .split(" ")[0] +
                                        " " +
                                        snapshot.data[index].author
                                            .split(" ")[1],
                                    style: TextStyle(
                                        color: Colors.white,
                                        //fontSize: 12,
                                        //fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic),
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                                  child: Text(
                                    (snapshot.data[index].description.length >
                                            150)
                                        ? snapshot.data[index].description
                                                .substring(0, 150) +
                                            "..."
                                        : snapshot.data[index].description,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class NewsDetails extends StatelessWidget {
  final News news;

  //default constructor, initialize news
  NewsDetails(this.news);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Hero(
            tag: news.author,
            child: Image.network(news.urlToImage),
          ),
          Text(news.title),
          Text(news.author),
          Text(news.publishedAt),
          Text(news.content),
          RaisedButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsWebView(news.url),
                ),),
          )
        ],
      ),
    );
  }
}

class NewsWebView extends StatelessWidget {
  final String url;
  NewsWebView(this.url);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WebView(initialUrl: url, javascriptMode: JavascriptMode.unrestricted);
  }
}
