import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paperstox_app/colors.dart';
import 'package:paperstox_app/views/stock_details.dart';
import './logout.dart';
import 'package:http/http.dart' as http;

class SearchView extends StatefulWidget {
  // const SearchView({Key? key}) : super(key: key);
  @override
  State<SearchView> createState() => _SearchView();
}

class _SearchView extends State<SearchView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var messages;
  static const baseUrl = 'https://finnhub.io';
  static const apiKey = 'c6m0etaad3i9dkni2fqg';
  var stockList;
  var watchlist;
  var res;
  var currentUser;
  var flag = false;
  final TextEditingController searchText = TextEditingController();

  static const border = OutlineInputBorder(
      borderRadius: BorderRadius.horizontal(left: Radius.circular(5)));

  fetchStock(searchString) {
    http
        .get(Uri.parse('$baseUrl/api/v1/search?q=$searchString&token=$apiKey'))
        .then((res) {
      setState(() => stockList = json.decode(res.body));
    });
  }

  fetchWatchlist() {
    firestore
        .collection("users")
        .where("uid", isEqualTo: auth.currentUser!.uid.toString())
        .get()
        .then((querySnapshot) {
      setState(() => watchlist = querySnapshot.docs[0]['watchlist']);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (watchlist == null) {
      fetchWatchlist();
    }
    CollectionReference users = firestore.collection('users');
    return Scaffold(
        appBar: AppBar(
            title: const Text("Search"),
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
          child: ListView(children: [
            TextField(
              controller: searchText,
              style: const TextStyle(color: Colors.white),
              cursorColor: greenAccent,
              decoration: InputDecoration(
                  fillColor: Colors.black,
                  filled: true,
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: blackPrimary),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: greenAccent)),
                  hintStyle: const TextStyle(color: greyHint),
                  border: const OutlineInputBorder(),
                  hintText: 'Search for a stock',
                  suffixIcon: Container(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            color: greenAccent,
                            onPressed: () {
                              searchText.clear();
                              setState(() {
                                stockList = null;
                              });
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              fetchStock(searchText.text);
                            },
                            icon: const Icon(Icons.search),
                            color: greenAccent,
                          ),
                        ],
                      ))),
            ),
            ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              addAutomaticKeepAlives: false,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: stockList != null ? stockList['count'] : 0,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StockDetails(
                          symbol: stockList['result'][index]['symbol'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      tileColor: Colors.black,
                      title: Text(stockList['result'][index]['description'],
                          style: const TextStyle(
                              color: greenAccent,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          "\n" + stockList['result'][index]['displaySymbol'],
                          style: const TextStyle(color: Colors.white)),
                      isThreeLine: true,
                      trailing: IconButton(
                        color: greenAccent,
                        icon: const Icon(Icons.add_box_outlined),
                        onPressed: () {
                          watchlist.forEach((stock) => {
                                if (stock['displaySymbol'] ==
                                    stockList['result'][index]['displaySymbol'])
                                  {flag = true}
                              });
                          if (flag == false) {
                            users.doc(auth.currentUser!.uid.toString()).update({
                              'watchlist': FieldValue.arrayUnion(
                                  [stockList['result'][index]]),
                            });
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Added to your watchlist"),
                            ));
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Already added to your watchlist"),
                            ));
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ]),
          color: Colors.black,
        ));
  }
}
