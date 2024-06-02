import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pubfix/Screen/home_dashboard.dart';
import 'package:pubfix/global/global_instances.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Récupérer le mot de passe stocké dans Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .get();

          String storedPassword = userDoc.get('password');

          // Comparer le mot de passe tapé avec celui récupéré
          if (_oldPasswordController.text.trim() != storedPassword) {
            commonVM.showSnackBar('Ancien mot de passe est incorrect', context);
            return;
          }

          // Créez une AuthCredential en utilisant l'email et l'ancien mot de passe
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _oldPasswordController.text.trim(),
          );

          // Ré-authentifiez l'utilisateur
          await user.reauthenticateWithCredential(credential);

          // Mettez à jour le mot de passe dans Firebase Authentication
          await user.updatePassword(_passwordController.text.trim());

          // Mettez à jour le mot de passe dans Firestore
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .update({'password': _passwordController.text.trim()});

          // Afficher une boîte de dialogue pour indiquer le succès
          _showSuccessDialog();
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          setState(() {
            _errorMessage = 'Ancien mot de passe est incorrect';
          });
        } else {
          setState(() {
            _errorMessage = e.message;
          });
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Succès'),
          content: const Text('Mot de passe mis à jour avec succès'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Home(initialTabIndex: 3),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  bool _isPasswordVisible = false;
  final bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changer le mot de passe'),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Home(initialTabIndex: 3),
              ),
            );
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 55,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre ancien mot de passe';
                    }
                    /*   if (value.length < 8) {
                      return "Le mot de passe doit comporter au moins 8 caractères.";
                    }*/
                    return null;
                  },
                  controller: _oldPasswordController,
                  obscureText: !_isPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    fillColor: Colors.blue,
                    prefixIcon: const Icon(Icons.lock),
                    labelText: "Ancien mot de passe",
                    hintText: "Taper votre ancien mot de passe",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color.fromARGB(255, 36, 138, 147),
                      ),
                      onPressed: () {
                        setState(() {
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nouveau mot de passe';
                    }
                    if (value.length < 8) {
                      return "Le mot de passe doit comporter au moins 8 caractères.";
                    }
                    return null;
                  },
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    fillColor: Colors.blue,
                    prefixIcon: const Icon(Icons.lock),
                    labelText: "Nouveau mot de passe",
                    hintText: "Taper votre nouveau mot de passe",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color.fromARGB(255, 36, 138, 147),
                      ),
                      onPressed: () {
                        setState(() {
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return "Les mots de passe ne correspondent pas.";
                    }
                    if (value.length < 8) {
                      return "Le mot de passe doit comporter au moins 8 caractères.";
                    }
                    return null;
                  },
                  controller: _confirmPasswordController,
                  obscureText: !_isPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    fillColor: Colors.blue,
                    prefixIcon: const Icon(Icons.lock),
                    labelText: "Confirmer le mot de passe",
                    hintText: "Confirmer votre mot de passe",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color.fromARGB(255, 36, 138, 147),
                      ),
                      onPressed: () {
                        setState(() {
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
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _changePassword,
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
                              "Mettre à jour le mot de passe",
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
            ],
          ),
        ),
      ),
    );
  }
}
