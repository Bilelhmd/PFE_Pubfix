import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pubfix/Model/Authentication/authentification_aut_model.dart';

class AuthenticateAutoriteViewModel {
  Future<autoritesModel?> getAutorites() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return null;
    }

    final docRef =
        FirebaseFirestore.instance.collection('Autorite').doc(currentUser.uid);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      return autoritesModel.fromDocument(docSnapshot);
    } else {
      return null;
    }
  }

  Future<String?> getAutoritePhotoFromFirestore() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('Utilisateur non connecté');
        return null;
      }

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Autorite')
          .doc(currentUser.uid)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        String? userPhotoPath = userData['Image'] as String?;

        if (userPhotoPath != null) {
          String downloadURL = await FirebaseStorage.instance
              .refFromURL(userPhotoPath)
              .getDownloadURL();
          return downloadURL;
        }
      } else {
        print('Document utilisateur non trouvé');
      }
    } catch (e) {
      print('Erreur lors de la récupération de la photo de l\'utilisateur: $e');
    }
    return null;
  }

  Widget buildProfileAvatar() {
    return FutureBuilder<String?>(
      future: getAutoritePhotoFromFirestore(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.error);
        } else if (snapshot.hasData && snapshot.data != null) {
          return CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(snapshot.data!),
          );
        } else {
          return const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/default_profile_image.jpg'),
          );
        }
      },
    );
  }

  Future<LatLng?> getAutoriteAddress() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Autorite')
        .doc(currentUser?.uid)
        .get();
    if (userSnapshot.exists) {
      String userAddress = userSnapshot['Adresse'];
      List<Location> locations = await locationFromAddress(userAddress);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
    }
    return null;
  }

  Future<Map<String, String?>> getAutoriteDetailsFromFirestore() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('Utilisateur non connecté');
        return {};
      }

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Autorite')
          .doc(currentUser.uid)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        String? userPhotoPath = userData['Image'] as String?;
        String? userName = userData['Nom'] as String?;
        String? userEmail = userData['Email'] as String?;

        String? downloadURL;
        if (userPhotoPath != null) {
          downloadURL = await FirebaseStorage.instance
              .refFromURL(userPhotoPath)
              .getDownloadURL();
        }

        return {
          'Image': downloadURL,
          'Nom': userName,
          'Email': userEmail,
        };
      } else {
        print('Document utilisateur non trouvé');
      }
    } catch (e) {
      print('Erreur lors de la récupération des détails de l\'utilisateur: $e');
    }
    return {};
  }
}
