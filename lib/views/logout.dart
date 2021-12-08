import 'package:flutter/material.dart';
import '../main.dart';

void showLogoutDialog(BuildContext context, auth) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
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
                MaterialPageRoute(builder: (context) => const PaperStox()),
              );
            },
          ),
        ],
      );
    },
  );
}
