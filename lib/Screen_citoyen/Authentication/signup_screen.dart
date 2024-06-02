import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pubfix/Screen_citoyen/Authentication/Login_screen.dart';
import 'package:pubfix/Screen_citoyen/Authentication/signup_welcome_screen.dart';
import 'package:pubfix/global/global_instances.dart';

class SignUpScreen extends StatefulWidget {
  // Class Page d'inscription
  const SignUpScreen({super.key}); // Constructeur de la classe SignUpScreen

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  //dropdown pour selectionner role

  // Clé globale pour le formulaire
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final _confirmpasswordcontroller = TextEditingController();
  final _namecontroller = TextEditingController();
  final _telephonecontroller = TextEditingController();

  String? nom;

  // Variables pour gérer la visibilité du mot de passe
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool passwordconfirm() {
    if (_passwordcontroller.text.trim() ==
        _confirmpasswordcontroller.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    _confirmpasswordcontroller.dispose();
    _namecontroller.dispose();
    _telephonecontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    File imageFile = File('assets/images/log.png');
    // final _formkey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          'Inscription',
          style: GoogleFonts.poppins(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Form(
                // key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TEXTFIELD NAME
                    TextFormField(
                      // widget pour la saisie de texte
                      onChanged: (value) {
                        nom = value;
                      },
                      controller: _namecontroller,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          prefixIcon: Icon(Icons.person_outline_outlined),
                          labelText: "Nom",
                          hintText: "Taper votre nom"),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    //TEXTFIELD EMAIL
                    TextFormField(
                      validator: (value) => value!.isEmpty
                          ? "L'e-mail ne peut pas être vide."
                          : null,
                      controller: _emailcontroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          prefixIcon: Icon(Icons.email),
                          labelText: "Email",
                          hintText: "Taper votre Email"),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    //TEXTFIELD TELEPHONE
                    TextFormField(
                      controller: _telephonecontroller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          prefixIcon: Icon(Icons.phone),
                          labelText: "N° Téléphone",
                          hintText: "Taper votre N° téléphone"),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    //TEXTFIELD PASSWORD
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        validator: (value) => value!.length < 8
                            ? "Le mot de passe doit au moins 8 caractères."
                            : null, // Validation de champ*/
                        controller: _passwordcontroller,
                        //        .password, // Contrôleur pour récupérer la valeur saisie
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
                      height: 8,
                    ),
                    //TEXTFIELD PASSWORDCONFIRM
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        validator: (value) => value!.length < 8
                            ? "Le mot de passe doit au moins 8 caractères."
                            : null, // Validation de champ*/
                        controller: _confirmpasswordcontroller,
                        //            .passwordConfirm, // Contrôleur pour récupérer la valeur saisie
                        obscureText:
                            !_isConfirmPasswordVisible, // Le champ de saisie du mot de passe est masqué

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
                              _isConfirmPasswordVisible
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
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),

                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        const SizedBox(height: 10),
                        Expanded(
                          child: ElevatedButton(
                            //  onPressed: signin,
                            onPressed: () async {
                              await authVM.ValidateSignUpForm(
                                  imageFile,
                                  _namecontroller.text.trim(),
                                  _telephonecontroller.text.trim(),
                                  _emailcontroller.text.trim(),
                                  _passwordcontroller.text.trim(),
                                  _confirmpasswordcontroller.text.trim(),
                                  context);
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.black26;
                                }
                                return const Color.fromARGB(255, 39, 222, 169);
                              }),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            child: const Text(
                              "Créer un compte",
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
                        //  SizedBox(
                        // width: double.infinity,
                        //  child:
                        Row(
                          children: [
                            //   const Spacer(),
                            OutlinedButton.icon(
                                icon: const Image(
                                  image: AssetImage("assets/images/google.png"),
                                  width: 12.0,
                                ),
                                onPressed: () async {
                                  final userCredential =
                                      await authVM.signInWithGoogle();
                                  if (userCredential != null) {
                                    // Handle successful sign-in (e.g., navigate to home screen)
                                    print('Google sign in canceled');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const WelcomeSignUp(),
                                        ));
                                  }
                                },
                                label: const Text("Gmail")),
                            const Spacer(),
                            OutlinedButton.icon(
                                icon: const Image(
                                  image:
                                      AssetImage("assets/images/facebook.png"),
                                  width: 18.0,
                                ),
                                onPressed: () {
                                  authVM.signInWithFacebook();
                                },
                                label: const Text("Facebook")),
                            const Spacer(),
                            OutlinedButton.icon(
                                icon: const Image(
                                  image: AssetImage("assets/images/apple.png"),
                                  width: 12.0,
                                ),
                                onPressed: () {},
                                label: const Text("Apple")),
                            //   const Spacer(),
                          ],
                        ),
                        //  ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Text("vous avez un compte ?"),
                        const SizedBox(
                          width: 5,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ));
                          },
                          child: const Text(
                            "Se connecter ",
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
    );
  }
}
