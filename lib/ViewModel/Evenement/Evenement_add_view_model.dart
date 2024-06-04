import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class Evenement_add_view_model {
  Future<void> validateEvenementForm(File? imageXFile, String titre,
      String description, String localisation, DateTime date) async {
    String? organisateur = await getNomOrganisateur();
    String downloadUrl = await uploadImageToStorage(imageXFile);
    await saveActualiteDataToFirestore(
        organisateur, downloadUrl, titre, description, localisation, date);
  }

  Future<String?> getNomOrganisateur() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userSnapshot =
        await _firestore.collection('Users').doc(currentUser?.uid).get();
    if (userSnapshot.exists) {
      return userSnapshot['name'];
    }
    return null;
  }

  Future<String> uploadImageToStorage(File? imageXFile) async {
    try {
      String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      fStorage.Reference storageRef = fStorage.FirebaseStorage.instance
          .ref()
          .child("Evenements_images")
          .child(fileName);
      fStorage.UploadTask uploadTask =
          storageRef.putFile(File(imageXFile!.path));
      fStorage.TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => {});
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      print('Erreur Firebase Storage: $error');
      throw error;
    }
  }

  Future<void> saveActualiteDataToFirestore(
      String? organisateur,
      String downloadUrl,
      String titre,
      String description,
      String lieu,
      DateTime date) async {
    await _firestore.collection("Evenement").add({
      'Organisateur': organisateur,
      'Description': description,
      'Titre': titre,
      'Lieu': lieu,
      'Date': date,
      'Image': downloadUrl,
    });
  }
}
