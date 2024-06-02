import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../Model/Authentication/authentication_model.dart';

class AuthenticateViewModel {
  /* Future<List<UsersModel>> getUtilisateurs() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    // Create a reference to your collection
    final collectionRef = FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid);
   // Query query = collectionRef.where("uid", isEqualTo: currentUser?.uid);
    final querySnapshot = await collectionRef.get();

  
  }*/
  Future<UsersModel?> getUtilisateurs() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return null;
    }

    // Créez une référence au document de l'utilisateur actuel
    final docRef =
        FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);

    // Récupérez le document
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Transformez le document en une instance de UsersModel
      return UsersModel.fromDocument(docSnapshot);
    } else {
      return null;
    }
  }

  Future<String?> getUserPhotoFromFirestore() async {
    try {
      // Récupérer l'utilisateur actuel
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('Utilisateur non connecté');
        return null;
      }

      // Récupérer le document de l'utilisateur depuis Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        // Cast pour éviter les warnings potentiels
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        String? userPhoto = userData['photo'] as String?;
        return userPhoto;
      } else {
        print('Document utilisateur non trouvé');
      }
    } catch (e) {
      print('Erreur lors de la récupération de la photo de l\'utilisateur: $e');
    }
    return null;
  }

  Future<LatLng?> getUserAddress() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser?.uid)
        .get();
    if (userSnapshot.exists) {
      String userAddress = userSnapshot['adresse'];
      List<Location> locations = await locationFromAddress(userAddress);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
    }
    return null;
  }
}
