import 'package:flutter/material.dart';
import 'package:paperstox_app/colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
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
            const Text(
              'Current Balance: 1560124',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
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
                      child: TextFormField(
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
                          hintText: 'Credit Balance',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 55,
                      width: 320,
                      child: ElevatedButton(
                        child: const Text('Enter amount to credit'),
                        style: ElevatedButton.styleFrom(
                            primary: greenAccent,
                            textStyle: const TextStyle(color: Colors.black)),
                        onPressed: () {},
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 16),
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
                        onPressed: () {},
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
