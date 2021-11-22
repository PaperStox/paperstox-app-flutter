import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_view.dart';
import 'messages_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);
  @override
  State<LoginView> createState() => _LoginPage();
}

class _LoginPage extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    final userNameController = TextEditingController();
    final passwordController = TextEditingController();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
            child: Column(children: [
          const Text(
            'PaperStox',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 420,
            width: 370,
            child: Card(
              color: const Color(0xff1e2124),
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
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      cursorColor: const Color(0xFF00b803),
                      controller: userNameController,
                      decoration: const InputDecoration(
                        fillColor: Colors.black,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff1e2124)),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00b803))),
                        hintStyle: TextStyle(color: Color(0xFF808080)),
                        border: OutlineInputBorder(),
                        hintText: 'Email',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 16),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      cursorColor: const Color(0xFF00b803),
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        fillColor: Colors.black,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff1e2124)),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00b803))),
                        hintStyle: TextStyle(color: Color(0xFF808080)),
                        border: OutlineInputBorder(),
                        hintText: 'Password',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 55,
                    width: 320,
                    child: ElevatedButton(
                      child: const Text('Log In'),
                      style: ElevatedButton.styleFrom(
                          primary: const Color(0xFF00b803),
                          textStyle: const TextStyle(color: Colors.black)),
                      onPressed: () async {
                        if (userNameController.text == "") {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Please enter a valid email"),
                          ));
                        } else if (passwordController.text == "") {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Please enter a valid password"),
                          ));
                        } else {
                          try {
                            UserCredential userCredential =
                                await auth.signInWithEmailAndPassword(
                                    email: userNameController.text,
                                    password: passwordController.text);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MessagesView(
                                      userCredential
                                          .user!.providerData[0].email!)),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Login successful"),
                            ));
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("No user found with that email"),
                              ));
                            } else if (e.code == 'wrong-password') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Incorrect password"),
                              ));
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(e.toString()),
                            ));
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    width: 320,
                    child: SignInButton(
                      Buttons.GoogleDark,
                      onPressed: () async {
                        final GoogleSignInAccount? googleUser =
                            await GoogleSignIn().signIn();

                        if (googleUser != null) {
                          try {
                            final GoogleSignInAuthentication googleAuth =
                                await googleUser.authentication;

                            final credential = GoogleAuthProvider.credential(
                              accessToken: googleAuth.accessToken,
                              idToken: googleAuth.idToken,
                            );

                            UserCredential result =
                                await auth.signInWithCredential(credential);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MessagesView(result
                                      .additionalUserInfo?.profile!['email'])),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Login successful"),
                            ));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(e.toString()),
                            ));
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                      children: <TextSpan>[
                        const TextSpan(text: 'Don\'t have an account? '),
                        TextSpan(
                            text: 'Sign Up',
                            style: const TextStyle(color: Color(0xFF00b803)),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpPage()),
                                );
                              }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ])),
      ),
    );
  }
}
