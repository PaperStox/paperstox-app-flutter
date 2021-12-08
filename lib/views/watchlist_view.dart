import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paperstox_app/colors.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class WatchlistView extends StatefulWidget {
  // const WatchlistView({Key? key}) : super(key: key);
  @override
  State<WatchlistView> createState() => _WatchlistView();
}

class _WatchlistView extends State<WatchlistView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var messages;
  static const baseUrl = 'https://finnhub.io';
  static const apiKey = 'c6m0etaad3i9dkni2fqg';
  var stockList;
  var res;
  final TextEditingController searchText = TextEditingController();

  static const border = OutlineInputBorder(
      borderRadius: BorderRadius.horizontal(left: Radius.circular(5)));

  fetchWatchlist() {
    firestore
        .collection("users")
        .where("uid", isEqualTo: auth.currentUser!.uid.toString())
        .get()
        .then((querySnapshot) {
      print(querySnapshot.docs.toString());
      setState(() => stockList = querySnapshot.docs[0]['watchlist']);
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = firestore.collection('users');
    if (stockList == null) {
      fetchWatchlist();
    }
    return Scaffold(
        appBar: AppBar(title: const Text("Watchlist"), actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.logout,
                  size: 25,
                ),
              )),
        ]),
        body: Container(
          child: ListView(children: [
            ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              addAutomaticKeepAlives: false,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: stockList != null ? stockList.length : 0,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    tileColor: Colors.black,
                    title: Text(stockList[index]['description'],
                        style: const TextStyle(
                            color: greenAccent,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(stockList[index]['displaySymbol'],
                        style: const TextStyle(color: greenAccent)),
                    isThreeLine: true,
                    trailing: IconButton(
                      color: greenAccent,
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        users.doc(auth.currentUser!.uid.toString()).update({
                          'watchlist':
                              FieldValue.arrayRemove([stockList[index]]),
                          // Add a snackbar when the stock is added to the watchlist
                        });
                        fetchWatchlist();
                      },
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
          ]),
          color: blackPrimary,
        ));
  }
}