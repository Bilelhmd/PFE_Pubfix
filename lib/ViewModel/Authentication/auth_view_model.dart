import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:pubfix/Screen/home_dashboard.dart';
import 'package:pubfix/Screen/welcome_screen.dart';
import 'package:pubfix/global/global_instances.dart';
import 'package:pubfix/global/global_var.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  ValidateSignUpForm(File? imageXFile, String name, String phone, String email,
      String password, String confirmpassword, BuildContext context) async {
    if (password == confirmpassword) {
      if (name.isNotEmpty &&
          email.isNotEmpty &&
          phone.isNotEmpty &&
          password.isNotEmpty &&
          confirmpassword.isNotEmpty) {
        String? downloadUrl;
        //signup
        User currentFirebaseUser =
            await createUserInFirebaseAuth(email, password, context);
        if (imageXFile != null) {
          downloadUrl = await UploadUserImageToStorage(imageXFile);
        }

        await saveUserDataToFirestore(currentFirebaseUser, name, email, phone,
            password, "Votre adresse", downloadUrl);

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()));

        commonVM.showSnackBar("Compte créé avec succès", context);
      } else {
        commonVM.showSnackBar("Veuillez remplir tous les champs", context);
        return;
      }
    } else {
      commonVM.showSnackBar("Mots de passes ne sont pas identique", context);
      return;
    }
  }

  createUserInFirebaseAuth(
      String email, String password, BuildContext context) async {
    User? currentFirebaseUser;
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((valueAuth) {
      currentFirebaseUser = valueAuth.user;
    }).catchError((errorMsg) {
      commonVM.showSnackBar(errorMsg, context);
    });
    if (currentFirebaseUser == null) {
      FirebaseAuth.instance.signOut();

      return;
    }
    return currentFirebaseUser;
  }

  saveUserDataToFirestore(currentFirebaseUser, name, email, phone, password,
      adresse, downloadUrl) async {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(currentFirebaseUser.uid)
        .set({
      "uid": currentFirebaseUser.uid,
      "email": email,
      "name": name,
      "phone": phone,
      "password": password,
      "adresse": adresse,
      "photo": downloadUrl,
    });

    await sharefPrefrences!.setString("uid", currentFirebaseUser.uid);
    await sharefPrefrences!.setString("email", email);
    await sharefPrefrences!.setString("name", name);
    await sharefPrefrences!.setString("phone", phone);
    await sharefPrefrences!.setString("password", password);
    await sharefPrefrences!.setString("adresse", adresse);
  }

  ValidateSigninForm(
      String email, String password, BuildContext context) async {
    // Proceed with login if validation passes
    try {
      User? currentFirebaseUser = await loginUser(email, password, context);
      String? token = await _firebaseMessaging.getToken();

      if (currentFirebaseUser != null) {
        try {
          await ReadFromFirestoreAndSetDataLocally(
              currentFirebaseUser, context);
          updateUserToken(token!);
        } catch (e) {
          commonVM.showSnackBar(e.toString(), context);
        }
        // Handle successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
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

  Future<void> updateUserToken(String token) async {
    try {
      User? currentFirebaseUser = FirebaseAuth.instance.currentUser;

      if (currentFirebaseUser != null) {
        final userTokenRef = FirebaseFirestore.instance
            .collection('Users')
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

  loginUser(email, password, context) async {
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

  ReadFromFirestoreAndSetDataLocally(
      User? currenFirebaseUser, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currenFirebaseUser!.uid)
        .get()
        .then((datasnapshot) async {
      if (datasnapshot.exists) {
        // Access and store retrieved data locally
        await sharefPrefrences!.setString("uid", currenFirebaseUser.uid);
        await sharefPrefrences!
            .setString("email", datasnapshot.data()!["email"]);
        await sharefPrefrences!.setString("name", datasnapshot.data()!["name"]);
        await sharefPrefrences!
            .setString("phone", datasnapshot.data()!["phone"]);
        await sharefPrefrences!
            .setString("password", datasnapshot.data()!["password"]);
      } else {
        commonVM.showSnackBar("cet utilisateur n'existe pas", context);
        FirebaseAuth.instance.signOut();
        return;
      }
    });
  }

  // Connexion avec Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        GoogleSignInAuthentication? googleAuth =
            await googleUser.authentication;

        AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        User? userr = userCredential.user;
        if (userr != null) {
          if (userCredential.additionalUserInfo!.isNewUser) {
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(userr.uid)
                .set({
              'name': userr.displayName,
              'uid': userr.uid,
              'PhotoProfile': userr.photoURL,
              'phone': userr.phoneNumber,
            });
          }
        }

        return userCredential;
      } else {
        /*    */
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        print('The account already exists with a different credential.');
      } else if (e.code == 'invalid-credential') {
        print('The credential is invalid');
      } else {
        print(e);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  logout() async {
    await deleteUserToken();
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  Future<void> deleteUserToken() async {
    try {
      User? currentFirebaseUser = FirebaseAuth.instance.currentUser;
      if (currentFirebaseUser != null) {
        // Récupérer le token actuel de l'utilisateur
        String? currentToken = await FirebaseMessaging.instance.getToken();
        if (currentToken != null) {
          final userTokenRef = FirebaseFirestore.instance
              .collection('Users')
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

  UploadUserImageToStorage(File? imageXFile) async {
    try {
      String downloadUrl = "";

      String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      fStorage.Reference storageRef = fStorage.FirebaseStorage.instance
          .ref()
          .child("UsersImages")
          .child(fileName);
      fStorage.UploadTask uploadTask =
          storageRef.putFile(File(imageXFile!.path));
      fStorage.TaskSnapshot tasksnapshot =
          await uploadTask.whenComplete(() => {});
      await tasksnapshot.ref.getDownloadURL().then((urlImage) {
        downloadUrl = urlImage;
      });
      return downloadUrl;
    } catch (error) {
      print('Erreur Firebase Storage : $error');
      // Gérer l'erreur de manière appropriée, par exemple afficher un message à l'utilisateur
    }
  }

  Future<void> updateUserData(
    File? imageXFile,
    // String currentUser,
    String nom,
    //String email,
    String phone,
    String password,
    String adresse,
    //  String imageUrl
  ) async {
    try {
      User? currentFirebaseUser = FirebaseAuth.instance.currentUser;
      String? downloadUrl;
      // Si une nouvelle image a été sélectionnée, télécharge-la et récupère l'URL
      if (imageXFile != null) {
        downloadUrl = await UploadUserImageToStorage(imageXFile);
      }

      // Référence à l'utilisateur dans la base de données
      final userRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentFirebaseUser?.uid);

      // Mettre à jour le statut de la réclamation
      //  await userRef.update({
      Map<String, dynamic> userDataToUpdate = {
        'name': nom,
        'password': password, // Ajouter le commentaire à la mise à jour
        'phone': phone,
        'adresse': adresse, // Ajouter le commentaire à la mise à jour
        //   'photo': downloadUrl,
      };

      // Si une nouvelle image a été téléchargée, ajoute l'URL de l'image au map
      if (downloadUrl != null) {
        userDataToUpdate['photo'] = downloadUrl;
      }

      // Mettre à jour les informations de l'utilisateur dans la base de données
      await userRef.update(userDataToUpdate);

      // Enregistrer les informations de l'utilisateur dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("name", nom);
      prefs.setString("phone", phone);
      prefs.setString("password", password);
      prefs.setString("adresse", adresse);
      if (downloadUrl != null) {
        prefs.setString("photo", downloadUrl);
      }
      buildProfileAvatar();
    } catch (error) {
      print(
          'Erreur lors de la mise à jour des coordonnées utilisateur : $error');
      rethrow;
    }
  }

  Widget buildProfileAvatar() {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          String photoUrl = snapshot.data?.getString("photo") ?? "";
          print(photoUrl + "bilel");
          return CircleAvatar(
            radius: 50,
            backgroundImage: photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : const AssetImage('assets/images/log.png')
                    as ImageProvider<Object>,
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  //GET USERS FROM FIRESTORE

  Future _getUserAddressFromFirestore() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Récupérer l'adresse de l'utilisateur actuel depuis Firestore
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser?.uid)
        .get();
    if (userSnapshot.exists) {
      String userName = userSnapshot['name'];
      String userAddress = userSnapshot['adresse'];
      String userPhone = userSnapshot['phone'];
      String userEmail = userSnapshot['email'];
      String userPhoto = userSnapshot['photo'];
    }
  }

  // Méthode pour convertir Timestamp en DateTime
  DateTime timestampToDateTime(Timestamp timestamp) {
    return timestamp.toDate();
  }

  // Méthode pour formater une date en chaîne de caractères
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  //CONNEXION AVEC FACEBOOK
  Future<void> signInWithFacebook() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status == LoginStatus.success) {
        final AccessToken accessToken = loginResult.accessToken!;
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        UserCredential userCredential =
            await auth.signInWithCredential(facebookAuthCredential);

        // L'utilisateur est maintenant connecté avec succès
        final User? user = userCredential.user;
        print(
            'Successfully signed in with Facebook. User: ${user?.displayName}');
      } else {
        print('Facebook login failed: ${loginResult.message}');
      }
    } catch (e) {
      print('Error during Facebook login: $e');
    }
  }
}
