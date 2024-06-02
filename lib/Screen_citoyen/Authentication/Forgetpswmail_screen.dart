import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordMailScreen extends StatefulWidget {
  const PasswordMailScreen({super.key});

  @override
  State<PasswordMailScreen> createState() => _PasswordMailScreenState();
}

class _PasswordMailScreenState extends State<PasswordMailScreen> {
  TextEditingController emailCont = TextEditingController();
  TextEditingController codeCont = TextEditingController();

  Future<void> sendEmailVerificationLink(String email) async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 70.0,
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("assets/images/forgot.png"),
                    width: 200.0,
                  ),
                  SizedBox(
                    height: 70.0,
                  ),
                  Text(
                    "Réinitialisation par Email",
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 70.0,
              ),
              Form(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: emailCont,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0))),
                        prefixIcon: Icon(Icons.email),
                        label: Text("Email"),
                        hintText: "Tapez votre Email"),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: codeCont,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0))),
                        prefixIcon: Icon(Icons.email),
                        label: Text("Email"),
                        hintText: "Tapez votre Email"),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () async {
                              FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: emailCont.text)
                                  .then((value) => Navigator.of(context).pop());
                            },
                            // icon: Icon(Icons.navigate_next),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                  255,
                                  87,
                                  178,
                                  121), // Set your desired background color

                              /* shape:
                                  MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)))*/
                            ),
                            child: const Text(
                              "Suivant",
                              style: TextStyle(
                                height: 3,
                                fontSize: 20.0, //fontWeight: FontWeight.bold
                                color: Colors.white,
                              ),
                            )),
                      ),
                    ],
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
