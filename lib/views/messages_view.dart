import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../models/stock_model.dart';

class MessagesView extends StatefulWidget {
  // const MessagesView({Key? key}) : super(key: key);
  @override
  State<MessagesView> createState() => _MessagesView();
}

class _MessagesView extends State<MessagesView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var messages;
  static const baseUrl = 'https://finnhub.io';
  static const apiKey = '';
  var res;

  Future<http.Response> fetchStock(searchString) {
    return http.get(
        Uri.parse('$baseUrl/api/v1/quote?symbol=$searchString&token=$apiKey'));
  }

  @override
  Widget build(BuildContext context) {
    print(res);

    return Scaffold(
        appBar: AppBar(title: const Text("Portfolio"), actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  showLogoutDialog(context);
                },
                child: const Icon(
                  Icons.logout,
                  size: 25,
                ),
              )),
        ]),
        body: Center(
          child: ListView.builder(
            itemCount: messages != null ? messages.length : 0,
            itemBuilder: (context, index) {
              return Card(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                          leading: const Icon(Icons.person, size: 60),
                          title: Text(messages[index]['full_name']),
                          subtitle: Text("\n" +
                              messages[index]['message'] +
                              "\n\n" +
                              DateFormat('d MMM y')
                                  .format(DateTime.fromMillisecondsSinceEpoch(
                                      messages[index]['tis']))
                                  .toString() +
                              " -- " +
                              DateFormat('jm')
                                  .format(DateTime.fromMillisecondsSinceEpoch(
                                      messages[index]['tis']))
                                  .toString()))));
            },
          ),
        ));
  }

  void showLogoutDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text("Logout"),
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
                await auth.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaperStox()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
