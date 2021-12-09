import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paperstox_app/colors.dart';
import '../main.dart';
import 'stock_details.dart';
import './logout.dart';

class Portfolio extends StatefulWidget {
  const Portfolio({Key? key}) : super(key: key);
  @override
  State<Portfolio> createState() => _Portfolio();
}

class _Portfolio extends State<Portfolio> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var portfolio;

  fetchPortfolio() {
    firestore
        .collection("users")
        .where("uid", isEqualTo: auth.currentUser!.uid.toString())
        .get()
        .then((querySnapshot) {
      var purchasedStocks = querySnapshot.docs[0]['bought_stocks'];
      setState(() => portfolio = purchasedStocks);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (portfolio == null) {
      fetchPortfolio();
    } else {
      print(portfolio);
    }

    return Scaffold(
        appBar: AppBar(
            title: const Text("Portfolio"),
            automaticallyImplyLeading: false,
            actions: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      showLogoutDialog(context, auth);
                    },
                    child: const Icon(
                      Icons.logout,
                      size: 25,
                    ),
                  )),
            ]),
        body: Container(
          color: Colors.black,
          child: Center(
            child: ListView.builder(
              itemCount: portfolio != null ? portfolio.length : 0,
              itemBuilder: (context, index) {
                if (portfolio[index]['count'] != 0) {
                  return Card(
                      color: Colors.black,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            title: Text(
                              portfolio[index]['ticker'],
                              style: const TextStyle(
                                  color: greenAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              if (portfolio[index] != null &&
                                  portfolio[index]['ticker'] != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StockDetails(
                                          symbol: portfolio[index]['ticker'])),
                                );
                              }
                            },
                            subtitle: Text(
                                "\n" +
                                    "Qty: " +
                                    portfolio[index]['count'].toString() +
                                    "   Avg price: " +
                                    portfolio[index]['avg_price'].toString() +
                                    "\n\n",
                                style: const TextStyle(color: Colors.white)),
                          )));
                } else {
                  return Container(
                    height: 0,
                  );
                }
              },
            ),
          ),
        ));
  }
}
