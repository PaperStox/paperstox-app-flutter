import 'dart:convert';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paperstox_app/colors.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:paperstox_app/views/login_view.dart';
import 'package:paperstox_app/views/portfolio.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockDetails extends StatefulWidget {
  const StockDetails({Key? key, required this.symbol}) : super(key: key);

  final String symbol;

  @override
  _StockDetailsState createState() => _StockDetailsState();
}

class _StockDetailsState extends State<StockDetails> {
  static const baseUrl = 'https://finnhub.io';
  static const apiKey = 'c6m0etaad3i9dkni2fqg';

  var stockDetails;
  var basicFinancials;
  var newsArray;
  var stockPriceDetails;
  var userId;

  double total_amount = 0;
  Map<String, dynamic> boughr_stocks = {};
  final no_of_stocks_controller = TextEditingController();

  // init state
  @override
  void initState() {
    super.initState();

    // get the userId
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginView()));
      }
      setState(() {
        userId = user!.uid;
      });

      print("userId is $userId");
    });

    // calling all the data related tot his symbol from api
    print('$baseUrl/api/v1/stock/profile2?symbol=AAPL&token=$apiKey');
    http
        .get(Uri.parse(
            '$baseUrl/api/v1/stock/profile2?symbol=${widget.symbol}&token=$apiKey'))
        .then((res) {
      print("stock details are : " + json.decode(res.body).toString());
      setState(() {
        stockDetails = json.decode(res.body);
      });
      //now also set up the basic financials
      http
          .get(Uri.parse(
              '$baseUrl/api/v1/stock/metric?symbol=${widget.symbol}&metric=all&token=$apiKey'))
          .then((res1) {
        print("basic financials are : " + json.decode(res1.body).toString());
        setState(() {
          basicFinancials = json.decode(res1.body);

          // get the news
          http
              .get(Uri.parse(
                  '$baseUrl/api/v1/company-news?symbol=${widget.symbol}&from=2021-09-01&to=2021-09-09&token=$apiKey'))
              .then((res2) {
            print("news details are : " + json.decode(res2.body).toString());
            setState(() {
              newsArray = json.decode(res2.body);

              http
                  .get(Uri.parse(
                      '$baseUrl/api/v1/quote?symbol=${widget.symbol}&token=$apiKey'))
                  .then((res3) {
                print("stock price details are : " +
                    json.decode(res3.body).toString());
                setState(() {
                  stockPriceDetails = json.decode(res3.body);
                });
              });
            });
          });
        });
      });
    });
  }

  void _launchURL(url_string) async {
    if (!await launch(url_string)) throw 'Could not launch $url_string';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Details")),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: <Widget>[
              // Expanded(child: Text("stock logo", textAlign: TextAlign.center))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0), //or 15.0
                    child: Container(
                      height: 100.0,
                      width: 100.0,
                      color: Color(0xffFF0E58),
                      child: Image.network(stockDetails != null &&
                              stockDetails != {}
                          ? stockDetails['logo']
                          : "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Phi_fenomeni.gif/50px-Phi_fenomeni.gif"),
                      // child:
                      //     Icon(Icons.volume_up, color: Colors.white, size: 50.0),
                    ),
                  ),
                ],
              ),

              const Padding(padding: EdgeInsets.only(top: 20.0)),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.symbol,
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    stockDetails != null && stockDetails != {}
                        ? stockDetails['name'].toString()
                        : "NA",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: greenAccent,
                  ),
                  padding: EdgeInsets.all(15.0),
                  // this is big row which shows metadata of stock
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          Text(
                            stockDetails != null && stockDetails != {}
                                ? stockDetails['exchange'].toString()
                                : "NA",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(5.0)),
                      Row(
                        children: <Widget>[
                          Text(
                              stockDetails != null && stockDetails != {}
                                  ? "Market Capitalization : " +
                                      stockDetails['marketCapitalization']
                                          .toString() +
                                      "(" +
                                      stockDetails['currency'].toString() +
                                      ")"
                                  : "Market Capitalization : NA",
                              style: TextStyle(color: Colors.white))
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(5.0)),
                      Row(
                        children: <Widget>[
                          Text(
                              stockDetails != null && stockDetails != {}
                                  ? "Industry : " +
                                      stockDetails['finnhubIndustry'].toString()
                                  : "Industry : NA",
                              style: TextStyle(color: Colors.white))
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Row(
                    children: const [
                      Text(
                        "• Basic Financials",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: greenAccent,
                  ),
                  padding: EdgeInsets.all(15.0),
                  // this is big row which shows metadata of stock
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          Text(
                              basicFinancials != null && basicFinancials != {}
                                  ? "52 Week High : " +
                                      basicFinancials['metric']['52WeekHigh']
                                          .toString()
                                  : "52 Week High : NA",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(5.0)),
                      Row(
                        children: <Widget>[
                          Text(
                              basicFinancials != null && basicFinancials != {}
                                  ? "52 Week High : " +
                                      basicFinancials['metric']['52WeekHigh']
                                          .toString() +
                                      " on (" +
                                      basicFinancials['metric']['52WeekLowDate']
                                          .toString() +
                                      ")"
                                  : "52 Week High : NA",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.all(5.0)),
                      Row(
                        children: <Widget>[
                          Text(
                              basicFinancials != null && basicFinancials != {}
                                  ? "P/E Ratio : " +
                                      basicFinancials['series']['annual']
                                              ['currentRatio'][0]['v']
                                          .toString()
                                  : "52 Week High : NA",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.all(5.0)),
                      Row(
                        children: <Widget>[
                          Text(
                              basicFinancials != null && basicFinancials != {}
                                  ? "Margin : " +
                                      basicFinancials['series']['annual']
                                              ['netMargin'][0]['v']
                                          .toString()
                                  : "52 Week High : NA",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.all(5.0)),
                      Row(
                        children: <Widget>[
                          Text(
                              stockPriceDetails != null &&
                                      stockPriceDetails != {}
                                  ? "Current Price : " +
                                      stockPriceDetails['c'].toString()
                                  : "NA",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Row(
                    children: const <Widget>[
                      Text(
                        "• In News",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              // news container
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    if (newsArray != null && newsArray.length > 0) {
                      _launchURL(newsArray[0]['url'].toString());
                    }
                  },
                  child: ListTile(
                    tileColor: Colors.white,
                    leading: newsArray != null && newsArray.length > 0
                        ? Image.network(newsArray[0]['image'].toString())
                        : Image.network(
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Phi_fenomeni.gif/50px-Phi_fenomeni.gif"),
                    title: newsArray != null && newsArray.length > 0
                        ? Text(newsArray[0]['headline'],
                            overflow: TextOverflow.ellipsis)
                        : const Text("NA"),
                    subtitle: newsArray != null && newsArray.length > 0
                        ? Text(newsArray[0]['summary'].length > 80
                            ? newsArray[0]['summary'].substring(0, 80) + "..."
                            : newsArray[0]['summary'])
                        : const Text("NA"),
                    isThreeLine: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // add bottom-navigation-bar-for buy and sell
    );
  }

  // add error dialogue for buy page

  // add error dialogue for sell page

}
