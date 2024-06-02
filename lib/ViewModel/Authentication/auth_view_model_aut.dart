import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pubfix/Screen/home_dashboard_Aut.dart';
import 'package:pubfix/global/global_instances.dart';
import 'package:pubfix/global/global_var.dart';

class AuthViewModelAut {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  ValidateSigninFormAut(
      String email, String password, BuildContext context) async {
    // Proceed with login if validation passes
    commonVM.showSnackBar("Vérification en cours...", context);
    try {
      User? currentFirebaseUser = await loginUserAut(email, password, context);
      String? token = await _firebaseMessaging.getToken();
      if (currentFirebaseUser != null) {
        try {
          await ReadFromFirestoreAndSetDataLocallyAut(
              currentFirebaseUser, context);
          updateAutoriteToken(token!);
        } catch (e) {
          commonVM.showSnackBar(e.toString(), context);
        }
        // Handle successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home_Aut()),
        );
      } else {
        // Handle login failure
        FirebaseAuth.instance.signOut();
        commonVM.showSnackBar(
            "Échec de la connexion. Veuillez vérifier vos identifiants.",
            context);
      }
    } catch (error) {
      // Handle other errors gracefully
      commonVM.showSnackBar(
          "Une erreur est survenue. Veuillez réessayer.", context);
      print(error); // Log the error for debugging
    }
  }

  loginUserAut(email, password, context) async {
    User? currentFirebaseUser;
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    currentFirebaseUser = userCredential.user;
    if (currentFirebaseUser == null) {
      FirebaseAuth.instance.signOut();
      return;
    } else {
      return currentFirebaseUser;
    }
  }

  ReadFromFirestoreAndSetDataLocallyAut(
      User? currenFirebaseUser, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("Autorite")
        .doc(currenFirebaseUser!.uid)
        .get()
        .then((datasnapshot) async {
      if (datasnapshot.exists) {
        // Access and store retrieved data locally
        await sharefPrefrences!.setString("uid", currenFirebaseUser.uid);
        await sharefPrefrences!.setString("nom", datasnapshot.data()!["Nom"]);
        await sharefPrefrences!
            .setString("email", datasnapshot.data()!["Email"]);
        await sharefPrefrences!
            .setString("password", datasnapshot.data()!["Password"]);
      } else {
        commonVM.showSnackBar("cet utilisateur n'existe pas", context);
        FirebaseAuth.instance.signOut();
        return;
      }
    });
  }

  uploadImageToStorage(imageXFile) {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    fStorage.Reference storageRef = fStorage.FirebaseStorage.instance
        .ref()
        .child("DemandeImages")
        .child(fileName);
    fStorage.UploadTask uploadTask = storageRef.putFile(File(imageXFile!.path));
  }

  Future<void> updateAutoriteToken(String token) async {
    try {
      User? currentFirebaseUser = FirebaseAuth.instance.currentUser;

      if (currentFirebaseUser != null) {
        final userTokenRef = FirebaseFirestore.instance
            .collection('Autorite')
            .doc(currentFirebaseUser.uid)
            .collection('Token');

        // Vérifiez si le token existe déjà
        final querySnapshot =
            await userTokenRef.where('fcmToken', isEqualTo: token).get();

        if (querySnapshot.docs.isEmpty) {
          // Si le token n'existe pas, ajoutez-le
          await userTokenRef.add({
            'fcmToken': token,
          });
        } else {
          print('Le token existe déjà.');
        }
      }
    } catch (error) {
      print(
          'Erreur lors de la mise à jour des coordonnées utilisateur : $error');
      rethrow;
    }
  }

  Future<void> deleteAutoriteToken() async {
    try {
      User? currentFirebaseUser = FirebaseAuth.instance.currentUser;
      if (currentFirebaseUser != null) {
        // Récupérer le token actuel de l'utilisateur
        String? currentToken = await FirebaseMessaging.instance.getToken();
        if (currentToken != null) {
          final userTokenRef = FirebaseFirestore.instance
              .collection('Autorite')
              .doc(currentFirebaseUser.uid)
              .collection('Token');

          // Cherchez le document avec le token actuel
          final tokenDocs = await userTokenRef
              .where('fcmToken', isEqualTo: currentToken)
              .get();
          for (var doc in tokenDocs.docs) {
            await doc.reference.delete();
          }
        }
      }
    } catch (error) {
      print('Erreur lors de la suppression du token utilisateur : $error');
    }
  }

  logout() async {
    await deleteAutoriteToken();
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }
}
