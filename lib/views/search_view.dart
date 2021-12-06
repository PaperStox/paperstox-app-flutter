import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paperstox_app/colors.dart';
import '../main.dart';
import 'package:intl/intl.dart';
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
  var res;
  var currentUser;
  final TextEditingController searchText = TextEditingController();

  static const border = OutlineInputBorder(
      borderRadius: BorderRadius.horizontal(left: Radius.circular(5)));

  fetchStock(searchString) {
    print('$baseUrl/api/v1/search?q=$searchString&token=$apiKey');
    http
        .get(Uri.parse('$baseUrl/api/v1/search?q=$searchString&token=$apiKey'))
        .then((res) {
      print("Stocklist is: " + json.decode(res.body).toString());
      setState(() => stockList = json.decode(res.body));
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = firestore.collection('users');
    return Scaffold(
        appBar: AppBar(title: const Text("Search"), actions: <Widget>[
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
                return Card(
                  child: ListTile(
                    tileColor: Colors.black,
                    title: Text(stockList['result'][index]['description'],
                        style: const TextStyle(
                            color: greenAccent,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(stockList['result'][index]['displaySymbol'],
                        style: const TextStyle(color: greenAccent)),
                    isThreeLine: true,
                    trailing: IconButton(
                      color: greenAccent,
                      icon: const Icon(Icons.add_box_outlined),
                      onPressed: () {
                        users.doc(auth.currentUser!.uid.toString()).update({
                          'watchlist': FieldValue.arrayUnion(
                              [stockList['result'][index]]),
                          // Add a snackbar when the stock is added to the watchlist
                        });
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
