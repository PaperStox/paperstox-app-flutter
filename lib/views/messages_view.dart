import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'package:intl/intl.dart';

class MessagesView extends StatefulWidget {
  final String email;
  MessagesView(this.email);
  @override
  State<MessagesView> createState() => _MessagesView(email);
}

class _MessagesView extends State<MessagesView> {
  final String email;
  _MessagesView(this.email);
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var userData;
  var messages;

  fetchMessages() {
    firestore
        .collection("messages")
        .orderBy("tis", descending: true)
        .get()
        .then((querySnapshot) {
      setState(() => messages = querySnapshot.docs);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      firestore
          .collection("users")
          .where('email', isEqualTo: email)
          .get()
          .then((querySnapshot) {
        setState(() => userData = querySnapshot.docs);
      });
    }

    if (messages == null && userData != null) {
      fetchMessages();
    }

    return Scaffold(
        appBar: AppBar(title: Text("Messages"), actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  showLogoutDialog(context);
                },
                child: Icon(
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
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                          leading: Icon(Icons.person, size: 60),
                          title: Text(messages[index]['full_name']),
                          subtitle: Text("\n" +
                              messages[index]['message'] +
                              "\n\n" +
                              DateFormat('d MMM y')
                                  .format(
                                      new DateTime.fromMillisecondsSinceEpoch(
                                          messages[index]['tis']))
                                  .toString() +
                              " -- " +
                              DateFormat('jm')
                                  .format(
                                      new DateTime.fromMillisecondsSinceEpoch(
                                          messages[index]['tis']))
                                  .toString()))));
            },
          ),
        ),
        floatingActionButton:
            userData != null && userData[0].data()['user_role'] == 'admin'
                ? FloatingActionButton(
                    onPressed: () {
                      showPostMessageDialog(context);
                    },
                    child: const Icon(Icons.add),
                    backgroundColor: Colors.blueAccent,
                  )
                : null);
  }

  void showPostMessageDialog(BuildContext context) {
    final messageController = TextEditingController();
    CollectionReference messsages = firestore.collection('messages');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("New Message"),
          content: TextField(
            controller: messageController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text("POST MESSAGE"),
              onPressed: () {
                messsages.add({
                  'message': messageController.text,
                  'email': email,
                  'full_name': userData[0].data()['first_name'] +
                      " " +
                      userData[0].data()['last_name'],
                  'tis': DateTime.now().millisecondsSinceEpoch,
                });
                fetchMessages();
                Navigator.of(context).pop();
              },
            ),
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("CLOSE"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showLogoutDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Logout"),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to log out?'),
              ],
            ),
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text("NO"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("YES"),
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
