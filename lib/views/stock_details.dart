import 'dart:convert';
import '../colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paperstox_app/colors.dart';
import 'package:http/http.dart' as http;
import 'package:paperstox_app/views/bottom_navbar.dart';
import 'package:paperstox_app/views/login_view.dart';
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
  var currentBalance;

  double total_amount = 0;
  Map<String, dynamic> bought_stocks = {};
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

      // get all transaction data
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          print('Document exists on the database');

          setState(() {
            currentBalance = documentSnapshot['balance'];
          });

          print("current balance is : " + currentBalance.toString());
        }
      });
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
                      color: Colors.white,
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
                    style: const TextStyle(
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
                    color: blackPrimary,
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
                    color: blackPrimary,
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
                    tileColor: blackPrimary,
                    leading: newsArray != null && newsArray.length > 0
                        ? Image.network(newsArray[0]['image'].toString())
                        : Image.network(
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Phi_fenomeni.gif/50px-Phi_fenomeni.gif"),
                    title: newsArray != null && newsArray.length > 0
                        ? Text(
                            newsArray[0]['headline'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        : const Text("NA"),
                    subtitle: newsArray != null && newsArray.length > 0
                        ? Text(
                            newsArray[0]['summary'].length > 80
                                ? newsArray[0]['summary'].substring(0, 80) +
                                    "..."
                                : newsArray[0]['summary'],
                            style: const TextStyle(
                                fontSize: 16.0, color: Colors.white),
                          )
                        : const Text("NA"),
                    isThreeLine: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: Material(
              color: greenAccent,
              child: InkWell(
                onTap: () {
                  //print('called on tap');
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: blackPrimary,
                          title: Text("Buy Stocks",
                              style: const TextStyle(color: Colors.white)),
                          content: Stack(
                            overflow: Overflow.visible,
                            children: <Widget>[
                              Positioned(
                                right: -40.0,
                                top: -80.0,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const CircleAvatar(
                                    child: Icon(Icons.close),
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),

                                    // text form field for buy stocks
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      cursorColor: greenAccent,
                                      controller: no_of_stocks_controller,
                                      onChanged: (val) {
                                        setState(() {
                                          total_amount = int.parse(val) *
                                              double.parse(
                                                  stockPriceDetails['c']
                                                      .toString());
                                          print(total_amount);
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        fillColor: Colors.black,
                                        filled: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: blackPrimary),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: greenAccent)),
                                        hintStyle: TextStyle(color: greyHint),
                                        border: OutlineInputBorder(),
                                        hintText: 'No of stocks to buy',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: stockPriceDetails != null
                                          ? Text(
                                              "LTP: \$" +
                                                  stockPriceDetails['c']
                                                      .toString(),
                                              style: const TextStyle(
                                                  color: Colors.white))
                                          : null),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      child:
                                          Text("Buy ${widget.symbol} stocks"),
                                      onPressed: () {
                                        if (stockPriceDetails != null) {
                                          // get the complete user data from backend
                                          if (currentBalance > total_amount) {
                                            // user can buy the stock
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userId)
                                                .get()
                                                .then((DocumentSnapshot
                                                    documentSnapshot) {
                                              if (documentSnapshot.exists) {
                                                Map<String, dynamic> data =
                                                    documentSnapshot.data()!
                                                        as Map<String, dynamic>;

                                                // get the transactions array from the database
                                                var transactions =
                                                    data['transactions'];

                                                // get the bought_stocks array from the database
                                                var bought_stocks =
                                                    data['bought_stocks'];

                                                // update transaction array
                                                Map<String, dynamic>
                                                    transaction_obj =
                                                    new Map<String, dynamic>();
                                                transaction_obj['symbol'] =
                                                    widget.symbol.toString();

                                                transaction_obj[
                                                        'company_name'] =
                                                    stockDetails['name']
                                                        .toString();

                                                transaction_obj[
                                                        'current_price'] =
                                                    stockPriceDetails['c']
                                                        .toString();

                                                transaction_obj['type'] =
                                                    stockPriceDetails['type'] =
                                                        "buy";

                                                transaction_obj['stock_logo'] =
                                                    stockDetails['logo']
                                                        .toString();

                                                transaction_obj[
                                                        'no_of_stocks'] =
                                                    no_of_stocks_controller
                                                        .text;

                                                transaction_obj[
                                                        'total_amount'] =
                                                    total_amount;

                                                transaction_obj['createdAt'] =
                                                    DateTime.now();

                                                transactions
                                                    .add(transaction_obj);

                                                // update the currentBalance
                                                var cBalance = currentBalance;
                                                cBalance =
                                                    cBalance - total_amount;

                                                var flag = 0;
                                                if (bought_stocks.length > 0) {
                                                  // check if stock is already present in it or not
                                                  for (int i = 0;
                                                      i < bought_stocks.length;
                                                      i++) {
                                                    var item = bought_stocks[i];
                                                    if (item['ticker']
                                                            .toString() ==
                                                        widget.symbol) {
                                                      // stocks are already bought at some time
                                                      flag = 1;
                                                    }
                                                  }
                                                }

                                                if (flag == 1) {
                                                  // stocks already bought
                                                  for (int i = 0;
                                                      i < bought_stocks.length;
                                                      i++) {
                                                    var item = bought_stocks[i];
                                                    if (item['ticker']
                                                            .toString() ==
                                                        widget.symbol) {
                                                      // go the object update it
                                                      var val = item['count'];
                                                      item['count'] = val +
                                                          int.parse(
                                                              no_of_stocks_controller
                                                                  .text);
                                                    }
                                                  }
                                                } else {
                                                  // user has not bought this stocks already
                                                  Map<String, dynamic>
                                                      bought_stock_obj =
                                                      new Map<String,
                                                          dynamic>();

                                                  bought_stock_obj['ticker'] =
                                                      widget.symbol.toString();

                                                  bought_stock_obj['count'] =
                                                      int.parse(
                                                          no_of_stocks_controller
                                                              .text);

                                                  if (bought_stock_obj[
                                                          'avg_price'] !=
                                                      null) {
                                                    bought_stock_obj[
                                                        'avg_price'] = double.parse(
                                                            bought_stock_obj[
                                                                'avg_price']) +
                                                        double.parse(
                                                                stockPriceDetails[
                                                                    'c']) /
                                                            2;
                                                  } else {
                                                    bought_stock_obj[
                                                            'avg_price'] =
                                                        stockPriceDetails['c'];
                                                  }

                                                  bought_stocks
                                                      .add(bought_stock_obj);
                                                }

                                                // push the data to firebase
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(userId)
                                                    .update({
                                                  'transactions': transactions,
                                                  'bought_stocks':
                                                      bought_stocks,
                                                  'balance': cBalance
                                                }).then((value) {
                                                  print(
                                                      "new document is updated");
                                                  setState(() {
                                                    total_amount = 0;
                                                  });
                                                  no_of_stocks_controller
                                                      .clear();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    content: Text("Bought"),
                                                  ));
                                                }).catchError((onError) => print(
                                                        "error occurred while creating new document"));
                                              } else {
                                                print(
                                                    "document does not exists in the datavbase");
                                              }
                                            });
                                          } else {
                                            // user cannot buy the stock
                                            showErrorDiaogForCurrentBalance(
                                                context);
                                          }
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      });
                },
                child: const SizedBox(
                  height: kToolbarHeight,
                  width: 100,
                  child: Center(
                    child: ElevatedButton(
                        onPressed: null,
                        child: Center(
                            child: Text("Buy",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white)))),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.red,
              child: InkWell(
                onTap: () {
                  //print('called on tap');
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: blackPrimary,
                          title: const Text("Sell Stocks",
                              style: TextStyle(color: Colors.white)),
                          content: Stack(
                            overflow: Overflow.visible,
                            children: <Widget>[
                              Positioned(
                                right: -40.0,
                                top: -80.0,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const CircleAvatar(
                                    child: Icon(Icons.close),
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),

                                    // text form field for buy stocks
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      cursorColor: greenAccent,
                                      controller: no_of_stocks_controller,
                                      onChanged: (val) {
                                        setState(() {
                                          total_amount = int.parse(val) *
                                              double.parse(
                                                  stockPriceDetails['c']
                                                      .toString());
                                          print(total_amount);
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        fillColor: Colors.black,
                                        filled: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: blackPrimary),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: greenAccent)),
                                        hintStyle: TextStyle(color: greyHint),
                                        border: OutlineInputBorder(),
                                        hintText: 'No of stocks to Sell',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                          stockPriceDetails != null &&
                                                  stockPriceDetails['c'] !=
                                                      null &&
                                                  stockPriceDetails['c'] != ""
                                              ? "LTP: \$" +
                                                  stockPriceDetails['c']
                                                      .toString()
                                              : "NA",
                                          style: const TextStyle(
                                              color: Colors.white))),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      child:
                                          Text("Sell ${widget.symbol} stocks"),
                                      onPressed: () {
                                        // get the complete user data from backend
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .get()
                                            .then((DocumentSnapshot
                                                documentSnapshot) {
                                          if (documentSnapshot.exists) {
                                            Map<String, dynamic> data =
                                                documentSnapshot.data()!
                                                    as Map<String, dynamic>;

                                            // get the transactions array from the database
                                            var transactions =
                                                data['transactions'];

                                            // get the bought_stocks map from the database
                                            var bought_stocks =
                                                data['bought_stocks'];

                                            // check if selling_stocks <= stocks that user have
                                            var flag = 0;
                                            // check if stock present in the database
                                            for (int i = 0;
                                                i < bought_stocks.length;
                                                i++) {
                                              var item = bought_stocks[i];
                                              if (item['ticker'] ==
                                                  widget.symbol) {
                                                flag = 1;
                                                break;
                                              }
                                            }

                                            if (flag == 1) {
                                              // stock present in the database;
                                              // check if user has enough stocks
                                              for (int i = 0;
                                                  i < bought_stocks.length;
                                                  i++) {
                                                var item = bought_stocks[i];
                                                if (item['ticker'] ==
                                                    widget.symbol) {
                                                  var val = item['count'];
                                                  if (int.parse(
                                                          no_of_stocks_controller
                                                              .text) <=
                                                      val) {
                                                    // user can sell the stock
                                                    Map<String, dynamic>
                                                        transaction_obj =
                                                        new Map<String,
                                                            dynamic>();
                                                    transaction_obj['symbol'] =
                                                        widget.symbol
                                                            .toString();

                                                    transaction_obj[
                                                            'company_name'] =
                                                        stockDetails['name']
                                                            .toString();

                                                    transaction_obj[
                                                            'current_price'] =
                                                        stockPriceDetails['c']
                                                            .toString();

                                                    transaction_obj['type'] =
                                                        "sell";

                                                    transaction_obj[
                                                            'stock_logo'] =
                                                        stockDetails['logo']
                                                            .toString();

                                                    transaction_obj[
                                                            'no_of_stocks'] =
                                                        no_of_stocks_controller
                                                            .text;

                                                    transaction_obj[
                                                            'total_amount'] =
                                                        total_amount;

                                                    transaction_obj[
                                                            'createdAt'] =
                                                        DateTime.now();

                                                    transactions
                                                        .add(transaction_obj);

                                                    item['count'] = val -
                                                        int.parse(
                                                            no_of_stocks_controller
                                                                .text);

                                                    // update the balance
                                                    var cBalance =
                                                        currentBalance;

                                                    cBalance =
                                                        cBalance + total_amount;

                                                    // push the data to firebase
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(userId)
                                                        .update({
                                                      'transactions':
                                                          transactions,
                                                      'bought_stocks':
                                                          bought_stocks,
                                                      'balance': cBalance
                                                    }).then((value) {
                                                      print(
                                                          "new document is updated");
                                                      setState(() {
                                                        total_amount = 0;
                                                      });
                                                      no_of_stocks_controller
                                                          .clear();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                        content: Text("Sold"),
                                                      ));
                                                    }).catchError((onError) =>
                                                            print(
                                                                "error occurred while creating new document"));
                                                  } else {
                                                    no_of_stocks_controller
                                                        .text = "";
                                                    showErrorDiaogForSellPage(
                                                        context);
                                                  }
                                                }
                                              }
                                            } else {
                                              no_of_stocks_controller.text = "";
                                              showErrorDiaogForSellPage(
                                                  context);
                                            }
                                          } else {
                                            //give an error
                                            print(
                                                "document does not exists in the datavbase");
                                          }
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      });
                },
                child: const SizedBox(
                  height: kToolbarHeight,
                  width: 100,
                  child: Center(
                    child: ElevatedButton(
                        onPressed: null,
                        child: Center(
                            child: Text("Sell",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white)))),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showErrorDiaogForBuyPage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Buy ${widget.symbol} stocks"),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to log out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("NO"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("YES"),
              onPressed: () async {
                // await auth.signOut();
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const PaperStox()),
                // );
              },
            ),
          ],
        );
      },
    );
  }

  void showErrorDiaogForSellPage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error!!"),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('You do not have enough stocks to sell.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showErrorDiaogForCurrentBalance(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error!!"),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('You do not have enough balance to purchase the stocks.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
