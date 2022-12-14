// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shechat/login/login.dart';
import 'package:shechat/welcome.dart';

class HomeDecide extends StatelessWidget {
  const HomeDecide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          // ignore: unrelated_type_equality_checks
          if (ConnectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          debugPrint(snapshot.data.toString());
          // if not female show the you are not allower screen
          
          if (snapshot.hasData) {
            return const WelcomePage();
          }
          return const MyLogin();
        }),
      ),
    );
  }
}
