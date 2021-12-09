import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom_navbar.dart';
import '../colors.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({Key? key}) : super(key: key);
  @override
  State<SignUpView> createState() => _SignUpView();
}

class _SignUpView extends State<SignUpView> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');

    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final retypePasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration"),
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Container(
            color: Colors.black,
            height: 580,
            width: 370,
            child: SingleChildScrollView(
              child: Card(
                color: blackPrimary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 16),
                      child: TextFormField(
                        controller: firstNameController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: greenAccent,
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
                          hintText: 'First name',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 16),
                      child: TextFormField(
                        controller: lastNameController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: greenAccent,
                        decoration: const InputDecoration(
                          fillColor: Colors.black,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff1e2124)),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: blackPrimary)),
                          hintStyle: TextStyle(color: greyHint),
                          border: OutlineInputBorder(),
                          hintText: 'Last name',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 16),
                      child: TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: greenAccent,
                        decoration: const InputDecoration(
                          fillColor: Colors.black,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff1e2124)),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: greenAccent)),
                          hintStyle: TextStyle(color: greyHint),
                          border: OutlineInputBorder(),
                          hintText: 'Email',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 16),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: greenAccent,
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
                          hintText: 'Password',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 16),
                      child: TextFormField(
                        controller: retypePasswordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: greenAccent,
                        decoration: const InputDecoration(
                          fillColor: Colors.black,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff1e2124)),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: greenAccent)),
                          hintStyle: TextStyle(color: greyHint),
                          border: OutlineInputBorder(),
                          hintText: 'Re-enter Password',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: 320,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: greenAccent,
                            textStyle: const TextStyle(color: Colors.black)),
                        onPressed: () async {
                          if (firstNameController.text == "") {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Please enter your first name"),
                            ));
                          } else if (lastNameController.text == "") {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Please enter your last name"),
                            ));
                          } else if (emailController.text == "") {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content:
                                  Text("Please enter a valid email address"),
                            ));
                          } else if (passwordController.text == "") {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Please enter a valid password"),
                            ));
                          } else if (passwordController.text !=
                              retypePasswordController.text) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Passwords do not match"),
                            ));
                          } else {
                            try {
                              UserCredential userCredential =
                                  await auth.createUserWithEmailAndPassword(
                                      email: emailController.text,
                                      password: passwordController.text);

                              users.doc(userCredential.user!.uid).set({
                                'first_name': firstNameController.text,
                                'last_name': lastNameController.text,
                                'email': emailController.text,
                                'uid': userCredential.user!.uid,
                                'watchlist': [],
                                'balance': 1000,
                                'transactions': [],
                                'bought_stocks': [],
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const BottomNavbarWidget()),
                              );

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content:
                                    Text("Registered a new user successfully"),
                              ));
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'weak-password') {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content:
                                      Text("The password provided is too weak"),
                                ));
                              } else if (e.code == 'email-already-in-use') {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      "An account already exists with that email"),
                                ));
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(e.toString()),
                              ));
                            }
                          }
                        },
                        child: const Text('Sign Up'),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
