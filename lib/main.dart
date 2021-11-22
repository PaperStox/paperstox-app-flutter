import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PaperStox());
}

class PaperStox extends StatelessWidget {
  const PaperStox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          fontFamily: 'Avenir Roman',
          appBarTheme: const AppBarTheme(
            color: Color(0xff1e2124),
          )),
      home: Scaffold(
        // backgroundColor: const Color(0x00000000),
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: const LoginView(),
      ),
    );
  }
}
