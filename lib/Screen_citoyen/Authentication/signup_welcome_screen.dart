import 'package:flutter/material.dart';
import 'package:pubfix/Screen_citoyen/Authentication/Login_screen.dart';

class WelcomeSignUp extends StatelessWidget {
  const WelcomeSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 25,
          ),
          const Image(image: AssetImage("assets/images/hello.png")),
          const SizedBox(
            height: 12,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt,
                color: Colors.green,
                size: 50,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Compte créé avec succès",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Center(
            child: Text(
              "Pour accéder à votre compte PubFix , cliquer sur le bouton suivant pour se connecter",
              textAlign: TextAlign.center,
              // style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ));
                    },
                    child: const Text(
                      "Suivant",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
