import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
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
        .collection("portfolio")
        // .orderBy("tis", descending: true)
        .get()
        .then((querySnapshot) {
      var res = querySnapshot.docs[0]['portfolios'];
      var port;
      res.forEach((user) => {
            if (user['uid'] == "123") {port = user['portfolio']}
          });
      setState(() => portfolio = port);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (portfolio == null) {
      fetchPortfolio();
    }

    return Scaffold(
        appBar: AppBar(title: const Text("Portfolio"), actions: <Widget>[
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
                return Card(
                    color: Colors.black,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text(
                            portfolio[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                          // subtitle: Text("\n" +
                          //     portfolio[index]['message'] +
                          //     "\n\n" +
                          //     DateFormat('d MMM y')
                          //         .format(DateTime.fromMillisecondsSinceEpoch(
                          //             portfolio[index]['tis']))
                          //         .toString() +
                          //     " -- " +
                          //     DateFormat('jm')
                          //         .format(DateTime.fromMillisecondsSinceEpoch(
                          //             portfolio[index]['tis']))
                          //         .toString())
                        )));
              },
            ),
          ),
        ));
  }

  // void showLogoutDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Logout"),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: const <Widget>[
  //               Text('Are you sure you want to log out?'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text("NO"),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text("YES"),
  //             onPressed: () async {
  //               await auth.signOut();
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => const PaperStox()),
  //               );
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
