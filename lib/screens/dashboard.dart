import '../logins/auth_class.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../logins/log_reg.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);
  // DashBoard(this.role);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  var format = DateFormat("d/M/y");
  var userId = "";

  FirebaseAuth auth = FirebaseAuth.instance;
  final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      .orderBy('createdAt')
      .snapshots();

  bool isDataFetched = false;

  var fireAuth = FireAuth();

  @override
  void initState() {
    super.initState();

    // if user is not signed in then send him to all login
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AllLogins()));
      }
      setState(() {
        userId = user!.uid;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          title: const Text('Login/Register',
              style: TextStyle(fontFamily: 'Raleway-Bold', fontSize: 22)),
        ),
      ),
    );
  }
}
