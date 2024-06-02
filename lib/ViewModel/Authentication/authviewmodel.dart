import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pubfix/Screen/home_dashboard.dart';
import 'package:pubfix/global/global_instances.dart';

class ConnexionEmail {
  createUserInFirebaseAuth(String email, String password, String name,
      String phoneNumber, BuildContext context) async {
    User? currentFirebaseUser;
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((valueAuth) async {
      currentFirebaseUser = valueAuth.user;
      await currentFirebaseUser?.sendEmailVerification();
      // Enregistrement dans la collection temporaire
      await FirebaseFirestore.instance
          .collection('TempUsers')
          .doc(currentFirebaseUser!.uid)
          .set({
        'email': email,
        'password': password,
        // Vous pouvez ajouter d'autres champs si nécessaire
      });
    }).catchError((errorMsg) {
      commonVM.showSnackBar(errorMsg.toString(), context);
    });

    if (currentFirebaseUser == null) {
      FirebaseAuth.instance.signOut();
      return;
    }

    // Vérification si l'email a été vérifié
    if (!currentFirebaseUser!.emailVerified) {
      FirebaseAuth.instance.signOut();
      commonVM.showSnackBar(
          "Veuillez vérifier votre e-mail pour activer votre compte", context);
      return;
    }
    // Déplacement vers la collection principale "Users"

    return currentFirebaseUser;
  }

  Future<User?> loginUserWithEmailPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? currentUser = userCredential.user;

      if (currentUser != null) {
        if (currentUser.emailVerified) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser.uid)
              .set({
            'email': email,
            'password': password,
            // Vous pouvez ajouter d'autres champs si nécessaire
          });

          // Suppression des données de la collection temporaire
          await FirebaseFirestore.instance
              .collection('TempUsers')
              .doc(currentUser.uid)
              .delete();
          // Utilisateur connecté avec succès et son email est vérifié
          // return currentUser;
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Home(),
              ));
        } else {
          // Utilisateur connecté mais son email n'est pas vérifié
          FirebaseAuth.instance.signOut();
          commonVM.showSnackBar(
              "Veuillez vérifier votre e-mail pour activer votre compte",
              context);
          return null;
        }
      } else {
        // Erreur lors de la connexion de l'utilisateur
        commonVM.showSnackBar(
            "Une erreur s'est produite lors de la connexion. Veuillez réessayer.",
            context);
        return null;
      }
    } catch (error) {
      // Erreur lors de la connexion de l'utilisateur
      commonVM.showSnackBar(error.toString(), context);
      return null;
    }
    return null;
  }
}
