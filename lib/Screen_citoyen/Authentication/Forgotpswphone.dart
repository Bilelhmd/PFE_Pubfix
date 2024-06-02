import 'package:flutter/material.dart';

class PasswordPhoneScreen extends StatefulWidget {
  const PasswordPhoneScreen({super.key});

  @override
  State<PasswordPhoneScreen> createState() => _PasswordPhoneScreenState();
}

class _PasswordPhoneScreenState extends State<PasswordPhoneScreen> {
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
                    "Réinitialisation par N° téléphone",
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
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0))),
                        prefixIcon: Icon(Icons.phonelink_lock_outlined),
                        label: Text("N° Téléphone"),
                        hintText: "Tapez votre N° téléphone"),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {},
                            // icon: Icon(Icons.navigate_next),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 87, 178,
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
