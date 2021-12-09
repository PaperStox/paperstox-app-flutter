import 'package:flutter/material.dart';
import 'package:paperstox_app/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paperstox_app/views/bottom_navbar.dart';
import 'package:paperstox_app/views/login_view.dart';
import 'package:paperstox_app/views/logout.dart';

class settingsView extends StatefulWidget {
  settingsView({Key? key}) : super(key: key);

  @override
  _settingsViewState createState() => _settingsViewState();
}

class _settingsViewState extends State<settingsView> {
  var userId;
  var currentBalance;

  final password_controller = TextEditingController();
  final credit_balance_controller = TextEditingController();
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
            currentBalance = documentSnapshot['balance'];
          });

          print("current balance is : " + currentBalance.toString());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Settings"),
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
              child: Column(children: [
            Text(
              'Current Balance: \$${currentBalance != null ? currentBalance.toStringAsFixed(2) : "NA"}',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 420,
              width: 370,
              child: Card(
                color: blackPrimary,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 16),

                      // text field for credit balance
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        controller: credit_balance_controller,
                        cursorColor: greenAccent,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          fillColor: Colors.black,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: blackPrimary),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: greenAccent)),
                          hintStyle: TextStyle(color: greyHint),
                          border: OutlineInputBorder(),
                          hintText: 'Credit Balance',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 55,
                      width: 320,
                      child: ElevatedButton(
                        child: const Text('Enter amount to credit'),
                        style: ElevatedButton.styleFrom(
                            primary: greenAccent,
                            textStyle: const TextStyle(color: Colors.black)),
                        onPressed: () {
                          // update balance of user in the database
                          var newBalance = currentBalance +
                              int.parse(credit_balance_controller.text);

                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .update({
                            'balance': newBalance,
                          }).then((value) {
                            print("new document is updated");
                            credit_balance_controller.clear();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const BottomNavbarWidget()),
                            );
                          }).catchError((onError) => print(
                                  "error occurred while creating new document"));
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 16),

                      // text field for password update
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        cursorColor: greenAccent,
                        obscureText: true,
                        decoration: InputDecoration(
                          fillColor: Colors.black,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: blackPrimary),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: greenAccent)),
                          hintStyle: TextStyle(color: greyHint),
                          border: OutlineInputBorder(),
                          hintText: 'Update Password',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 55,
                      width: 320,
                      child: ElevatedButton(
                        child: const Text('Update Password'),
                        style: ElevatedButton.styleFrom(
                            primary: greenAccent,
                            textStyle: const TextStyle(color: Colors.black)),
                        onPressed: () {
                          // update the password of user in the database
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ])),
        ),
      ),
    );
  }
}
