import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pubfix/Screen/OnBoarding/OnBoarding.dart';
import 'package:pubfix/Screen/home_dashboard.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return const Home();
            // return Dashboard();
          } else {
            return const OnboardingScreen();
          }
        }),
      ),
    );
  }
}
