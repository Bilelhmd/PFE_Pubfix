import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class Actualite_add_view_model {
  Future<void> validateActualiteForm(File? imageXFile, String titre,
      String description, String localisation, DateTime date) async {
    String? autoritename = await getNomAutorite();
    String downloadUrl = await uploadImageToStorage(imageXFile);
    await saveActualiteDataToFirestore(
        autoritename, downloadUrl, titre, description, localisation, date);
    List<String> tokens = await getCitizenTokens();
    await sendNotification(titre, description, tokens);
    await saveNotificationUser(titre, description);
    print('mohamed');
  }

  Future<List<String>> getCitizenTokens() async {
    List<String> tokens = [];
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Users').get();

      for (var doc in querySnapshot.docs) {
        // Récupérer les tokens de la sous-collection Token pour chaque utilisateur
        QuerySnapshot tokenSnapshot =
            await doc.reference.collection('Token').get();
        for (var tokenDoc in tokenSnapshot.docs) {
          if (tokenDoc['fcmToken'] != null) {
            tokens.add(tokenDoc['fcmToken']);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des tokens FCM : $e');
    }
    return tokens;
  }

  Future<String> uploadImageToStorage(File? imageXFile) async {
    try {
      String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      fStorage.Reference storageRef = fStorage.FirebaseStorage.instance
          .ref()
          .child("RapportsImages")
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
      String? autoritename,
      String downloadUrl,
      String titre,
      String description,
      String localisation,
      DateTime date) async {
    await _firestore.collection("Actualite").add({
      'Autorite': autoritename,
      'Description': description,
      'Titre': titre,
      'Localisation': localisation,
      'Date': date,
      'Image': downloadUrl,
    });
  }

  Future<void> sendNotification(
      String titre, String description, List<String> tokens) async {
    const String serverToken =
        'AAAAkOPa5Kc:APA91bHLBTRQr2qsjWuUGl4mp3bXEnemZ3waRbTSlzMprdPVHoWc1xkpoORtAZi7dkpvMJuKT4Xq5vaqXZYJVuAOrKqVhieOUBoGiMe179Dal7q5-EwHb5ue8RYjYYCpBCpznCQxBHOX';

    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverToken',
    };

    for (String token in tokens) {
      final body = json.encode({
        'to': token,
        'notification': {
          'title': titre,
          'body': description,
        },
      });
      print("bilel" + token.toString());
      try {
        final response = await http.post(url, headers: headers, body: body);
        if (response.statusCode == 200) {
          print("Notification envoyée avec succès à $token");
        } else {
          print(
              "Erreur lors de l'envoi de la notification à $token: ${response.body}");
        }
      } catch (e) {
        print("Erreur: $e");
      }
    }
  }

  Future<void> saveNotificationUser(String title, String description) async {
    try {
      print('mohamed');
      // Récupérer tous les documents dans la collection "Users"
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('Users').get();

      if (usersSnapshot.docs.isNotEmpty) {
        // Parcourir tous les documents et ajouter la notification à chacun si fcmToken existe
        for (var userDoc in usersSnapshot.docs) {
          String userId = userDoc.id;

          // Récupérer les tokens de la sous-collection "Token" de l'utilisateur
          QuerySnapshot tokenSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .collection('Token')
              .get();

          bool hasFcmToken = false;

          // Vérifier si un document avec 'fcmToken' existe dans la sous-collection "Token"
          for (var tokenDoc in tokenSnapshot.docs) {
            if (tokenDoc['fcmToken'] != null &&
                tokenDoc['fcmToken'].isNotEmpty) {
              print('mohamed: $userId, FCM Token: ${tokenDoc['fcmToken']}');
              hasFcmToken = true;
              break;
            }
          }

          // Si l'utilisateur a un fcmToken, ajouter la notification à sa sous-collection "Notification"
          if (hasFcmToken) {
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(userId)
                .collection('Notification')
                .add({
              'title': title,
              'body': description,
              'timestamp': Timestamp.now(),
            });
          }
        }

        print(
            'Notification enregistrée avec succès pour les utilisateurs actifs');
      } else {
        print('Aucun utilisateur trouvé.');
      }
    } catch (e) {
      print('Erreur lors de l\'enregistrement de la notification: $e');
    }
  }

  Future<String?> getNomAutorite() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userSnapshot =
        await _firestore.collection('Autorite').doc(currentUser?.uid).get();
    if (userSnapshot.exists) {
      return userSnapshot['Nom'];
    }
    return null;
  }

  Future<void> fetchAndMarkAddress(Set<Marker> markeur) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('Actualite').get();
      for (var doc in querySnapshot.docs) {
        String address = doc['Localisation'];
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          Location location = locations.first;
          LatLng position = LatLng(location.latitude, location.longitude);
          final marker = Marker(
            markerId: MarkerId(position.toString()),
            position: position,
            infoWindow: InfoWindow(
              title: doc['Titre'],
              snippet: doc['Description'],
            ),
          );
          markeur.add(marker);
        }
      }
    } catch (e) {
      print(
          'Erreur lors de la récupération des adresses depuis Firestore : $e');
    }
  }
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveData(Map<String, dynamic> data) async {
    try {
      await _db.collection('Actualite').add(data);
      print("Actualité ajoutée avec succès");
    } catch (e) {
      print("Erreur lors de l'ajout de données: $e");
      // Gérer l'erreur
    }
  }
}
