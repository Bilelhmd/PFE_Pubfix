import 'package:flutter/material.dart';
import 'package:pubfix/Screen/home_dashboard.dart';
import 'package:pubfix/Screen_citoyen/Authentication/signup_screen.dart';
import 'package:pubfix/Screen_citoyen/Authentication/verif.dart';
import 'package:pubfix/global/global_instances.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
            child: Padding(
              padding: const EdgeInsets.all(15.0),
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
                          controller: _emailcontroller,
                          validator: (value) => value!.isEmpty
                              ? "L'e-mail ne peut pas être vide."
                              : null,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              prefixIcon: Icon(Icons.email_rounded),
                              labelText: "Email",
                              hintText: "Tapez votre Email"),
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Faire une sélection",
                                        style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                          "Choisissez l'une des options ci-dessous pour réinitialiser votre mot de passe"),
                                      const SizedBox(
                                        height: 30.0,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const PasswordResetScreen(),
                                              ));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(20.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.grey.shade200,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.mail_outline_rounded,
                                                size: 60.0,
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Email",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge,
                                                  ),
                                                  const Text(
                                                      "Réinitialisation avec Email")
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          padding: const EdgeInsets.all(20.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.grey.shade200,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.phone,
                                                size: 60.0,
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "N° Téléphone",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge,
                                                  ),
                                                  const Text(
                                                      "Réinitialisation avec N° téléphone")
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Mot de passe oublié ?",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
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
                                  await authVM.ValidateSigninForm(
                                      _emailcontroller.text.trim(),
                                      _passwordcontroller.text.trim(),
                                      context);
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
                                  }),
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
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Ou"),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                //   const Spacer(),
                                OutlinedButton.icon(
                                    icon: const Image(
                                      image: AssetImage(
                                          "assets/images/google.png"),
                                      width: 12.0,
                                    ),
                                    onPressed: () async {
                                      final userCredential =
                                          await authVM.signInWithGoogle();
                                      if (userCredential != null) {
                                        // Handle successful sign-in (e.g., navigate to home screen)
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Home(),
                                            ));
                                      }
                                    },
                                    label: const Text("Gmail")),
                                const Spacer(),
                                OutlinedButton.icon(
                                    icon: const Image(
                                      image: AssetImage(
                                          "assets/images/facebook.png"),
                                      width: 20.0,
                                    ),
                                    onPressed: () {},
                                    label: const Text("Facebook")),
                                const Spacer(),
                                OutlinedButton.icon(
                                    icon: const Image(
                                      image:
                                          AssetImage("assets/images/apple.png"),
                                      width: 12.0,
                                    ),
                                    onPressed: () {},
                                    label: const Text("Apple")),
                                //   const Spacer(),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Text("vous n'êtes pas un compte ?"),
                            const SizedBox(
                              width: 5,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen(),
                                    ));
                              },
                              child: const Text(
                                "Créer un ici",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 39, 222, 169),
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
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
