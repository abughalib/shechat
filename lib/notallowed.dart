import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shechat/login/home_decide.dart';

class NotAllowedScren extends StatefulWidget {
  const NotAllowedScren({super.key});

  @override
  State<NotAllowedScren> createState() => _NotAllowedScrenState();
}

class _NotAllowedScrenState extends State<NotAllowedScren> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pinkAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You are not allowed to use this app',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: const Text('Go Back'),
              onPressed: () async {
                // go to
                await FirebaseAuth.instance.signOut();
                // ignore: use_build_context_synchronously
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeDecide()),
                    (route) => false);
              },
            )
          ],
        ),
      ),
    );
  }
}
