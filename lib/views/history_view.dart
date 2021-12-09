import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paperstox_app/colors.dart';
import 'package:paperstox_app/views/login_view.dart';
import 'package:paperstox_app/views/logout.dart';
import 'package:paperstox_app/views/stock_details.dart';
import '../constants.dart' as Constants;

class historyView extends StatefulWidget {
  historyView({Key? key}) : super(key: key);

  @override
  _historyViewState createState() => _historyViewState();
}

class _historyViewState extends State<historyView> {
  static const baseUrl = Constants.baseUrl;
  static const apiKey = Constants.apiKey;
  var format = DateFormat("d/M/y hh:mm a");
  var transaction_data;
  var userId;
  final FirebaseAuth auth = FirebaseAuth.instance;

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
            transaction_data = documentSnapshot['transactions'];
          });

          print(transaction_data);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("History"),
            automaticallyImplyLeading: false,
            actions: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      // add the signout in history page
                      showLogoutDialog(context, auth);
                    },
                    child: const Icon(
                      Icons.logout,
                      size: 25,
                    ),
                  )),
            ]),
        backgroundColor: Colors.black,
        body: transaction_data != null && transaction_data.length > 0
            ? ListView.builder(
                itemCount:
                    transaction_data != null && transaction_data.length > 0
                        ? transaction_data.length
                        : 0,
                itemBuilder: (context, index) {
                  if (transaction_data[index]['type'].toString() == "buy") {
                    return InkWell(
                      onTap: () {
                        print(transaction_data[index]['symbol']);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StockDetails(
                              symbol: transaction_data[index]['symbol'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        child: ListTile(
                          tileColor: Colors.black,
                          leading: Image.network(transaction_data[index]
                                          ['stock_logo'] !=
                                      null &&
                                  transaction_data[index]['stock_logo'] != ""
                              ? transaction_data[index]['stock_logo']
                              : "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Phi_fenomeni.gif/50px-Phi_fenomeni.gif"),
                          title: Text(
                            "${transaction_data[index]['symbol']} (${transaction_data[index]['company_name']})",
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "stocks : ${transaction_data[index]['no_of_stocks']}" +
                                " | total amount : ${transaction_data[index]['total_amount']}" +
                                "\n"
                                    "bought on ${format.format(transaction_data[index]['createdAt'].toDate()).toString()}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: Text(""),
                          isThreeLine: true,
                        ),
                      ),
                    );
                  } else {
                    return InkWell(
                      onTap: () {
                        print(transaction_data[index]['symbol']);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StockDetails(
                              symbol: transaction_data[index]['symbol'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        child: ListTile(
                          tileColor: Colors.black,
                          leading: Image.network(transaction_data[index]
                                          ['stock_logo'] !=
                                      null &&
                                  transaction_data[index]['stock_logo'] != ""
                              ? transaction_data[index]['stock_logo']
                              : "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Phi_fenomeni.gif/50px-Phi_fenomeni.gif"),
                          title: Text(
                            "${transaction_data[index]['symbol']} (${transaction_data[index]['company_name']})",
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "stocks : ${transaction_data[index]['no_of_stocks']}" +
                                " | total amount : ${transaction_data[index]['total_amount']}" +
                                "\n"
                                    "sold on ${format.format(transaction_data[index]['createdAt'].toDate()).toString()}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: Text(""),
                          isThreeLine: true,
                        ),
                      ),
                    );
                  }
                })
            : const Center(
                child: CircularProgressIndicator(color: Colors.white)));
  }
}
