import 'package:flutter/material.dart';
import 'package:pubfix/global/global_instances.dart';

class LoginScreen_Aut extends StatefulWidget {
  const LoginScreen_Aut({super.key});

  @override
  State<LoginScreen_Aut> createState() => _LoginScreen_AutState();
}

class _LoginScreen_AutState extends State<LoginScreen_Aut> {
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    super.dispose();
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final controller = Get.put(LoginController());
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text(
          'Connexion',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  const Text(
                    "Se connecter à PubFix.",
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          autofocus: true,
                          controller: _emailcontroller,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              prefixIcon: Icon(Icons.email_rounded),
                              labelText: "Email",
                              hintText: "Tapez votre Email",
                              suffixText: "@pubfix.com"),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: TextFormField(
                            validator: (value) => value!.length < 8
                                ? "Le mot de passe doit au moins 8 caractères."
                                : null, // Validation de champ
                            controller:
                                _passwordcontroller, // Contrôleur pour récupérer la valeur saisie
                            obscureText:
                                !_isPasswordVisible, // Le champ de saisie du mot de passe est masqué

                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              fillColor: Colors.blue,
                              prefixIcon: const Icon(Icons.lock),
                              labelText: "Mot de passe",
                              hintText: "Taper votre mot de passe",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  // color: Theme.of(context).primaryColorDark,
                                  color: const Color.fromARGB(
                                      255, 36, 138, 147), // Couleur de l'icône
                                ),
                                onPressed: () {
                                  // Action lorsque l'utilisateur appuie sur l'icône
                                  setState(() {
                                    // Inverse la visibilité du mot de passe
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Padding(
                              // Add padding for bottom spacing
                              padding: EdgeInsets.only(bottom: 50.0),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Check if email and password are not empty
                                  if (_emailcontroller.text.trim().isEmpty ||
                                      _passwordcontroller.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Veuillez saisir votre email et votre mot de passe.'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                    return;
                                  }
                                  String email =
                                      "${_emailcontroller.text.trim()}@pubfix.com";
                                  // Perform sign in
                                  await authAutVM.ValidateSigninFormAut(
                                    email,
                                    _passwordcontroller.text.trim(),
                                    context,
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                    (states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return Colors.black26;
                                      }
                                      return const Color.fromARGB(
                                          255, 39, 222, 169);
                                    },
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  "Se connecter",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          padding: const EdgeInsets.all(20.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.grey.shade200,
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.mail_outline_rounded,
                                                size: 60.0,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(
                                                width: 20.0,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Voulez-vous envoyer votre demande à l'administration ?",
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10.0,
                                                    ),
                                                    Text(
                                                      "Cliquez ici pour envoyer votre demande à l'administration afin de récupérer votre mot de passe.",
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Mot de passe oublié ?",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
