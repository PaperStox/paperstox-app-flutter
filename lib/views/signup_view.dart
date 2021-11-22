import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'messages_view.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  @override
  State<SignUpPage> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
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
        title: Text("Registration"),
      ),
      body: Center(
        child: Container(
          height: 580,
          width: 370,
          child: SingleChildScrollView(
            child: Card(
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        // errorText: 'Error',
                        labelText: 'First name',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 16),
                    child: TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        // errorText: 'Error',
                        labelText: 'Last name',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 16),
                    child: TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        // errorText: 'Error',
                        labelText: 'Email',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 16),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        // errorText: 'Error',
                        labelText: 'Password',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 16),
                    child: TextFormField(
                      controller: retypePasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        // errorText: 'Error',
                        labelText: 'Re-enter Password',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    width: 320,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 14)),
                      onPressed: () async {
                        if (firstNameController.text == "") {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Please enter your first name"),
                          ));
                        } else if (lastNameController.text == "") {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Please enter your last name"),
                          ));
                        } else if (emailController.text == "") {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Please enter a valid email address"),
                          ));
                        } else if (passwordController.text == "") {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Please enter a valid password"),
                          ));
                        } else if (passwordController.text !=
                            retypePasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Passwords do not match"),
                          ));
                        } else {
                          try {
                            UserCredential userCredential =
                                await auth.createUserWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text);

                            users.add({
                              'first_name': firstNameController.text,
                              'last_name': lastNameController.text,
                              'user_role': 'customer',
                              'tis': DateTime.now().millisecondsSinceEpoch,
                              'email': emailController.text
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MessagesView(
                                      userCredential
                                          .user!.providerData[0].email!)),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("Registered a new user successfully"),
                            ));
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content:
                                    Text("The password provided is too weak"),
                              ));
                            } else if (e.code == 'email-already-in-use') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    "An account already exists with that email"),
                              ));
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
    );
  }
}
