import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pubfix/global/global_instances.dart';

class connCode {
// Fonction pour générer un code aléatoire de 6 chiffres
  String generateRandomCode() {
    Random random = Random();
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }

  createUserInFirebaseAuth(String email, String password, String name,
      String phoneNumber, BuildContext context) async {
    User? currentFirebaseUser;
    String verificationCode = generateRandomCode(); // Générer le code aléatoire

    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((valueAuth) async {
      currentFirebaseUser = valueAuth.user;

      // Enregistrement du code dans la base de données
      await FirebaseFirestore.instance
          .collection('TempUsers')
          .doc(currentFirebaseUser!.uid)
          .set({
        'email': email,
        'password': password,
        'verification_code': verificationCode, // Stocker le code
      });
    }).catchError((errorMsg) {
      commonVM.showSnackBar(errorMsg.toString(), context);
    });

    if (currentFirebaseUser == null) {
      FirebaseAuth.instance.signOut();
      return;
    }

    // Affichage du code à l'utilisateur
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Code de vérification"),
          content: Text("Votre code de vérification est : $verificationCode"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    // Déplacement vers la collection principale "Users"
    return currentFirebaseUser;
  }

  Future<bool> verifyVerificationCode(
      String email, String verificationCode) async {
    try {
      // Récupération de l'utilisateur avec l'email et le code de vérification
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('TempUsers')
          .where('email', isEqualTo: email)
          .where('verification_code', isEqualTo: verificationCode)
          .limit(1)
          .get();

      // Si un utilisateur correspondant est trouvé, le code est correct
      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print("Error verifying verification code: $error");
      return false;
    }
  }

// Fonction pour vérifier le code lors de la connexion
  Future<User?> loginUserWithVerificationCode(
      String email, String password, BuildContext context) async {
    try {
      // Récupération de l'utilisateur
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('TempUsers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
    } catch (error) {
      // Erreur lors de la connexion de l'utilisateur
      commonVM.showSnackBar(error.toString(), context);
    }
    return null;
  }
}
