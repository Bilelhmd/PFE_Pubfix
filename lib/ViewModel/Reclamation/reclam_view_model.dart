import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:http/http.dart' as http;

//final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ReclamViewModel {
  validatereclamationForm(
      String id,
      String imageXFile,
      String UserName,
      String adresse,
      String service,
      String cible,
      String description,
      String uidDemandeur,
      String phone) async {
    try {
      User? currentFirebaseUser = FirebaseAuth.instance.currentUser;
      String downloadUrl = imageXFile;

      await savereclamationDataToFirestore(id, downloadUrl, UserName,
          description, service, adresse, cible, uidDemandeur, phone);
      List<String> tokens = await getAutorityTokensByCible(cible);
      await sendNotificationToAutority(service, description, tokens);
      await saveNotificationAutority(cible, service, description);
    } catch (e) {
      print("riadh$e");
    }
  }

  UploadImageToStorage(File? imageXFile) async {
    String downloadUrl = "";

    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    fStorage.Reference storageRef = fStorage.FirebaseStorage.instance
        .ref()
        .child("RapportsImages")
        .child(fileName);
    fStorage.UploadTask uploadTask = storageRef.putFile(File(imageXFile!.path));
    fStorage.TaskSnapshot tasksnapshot =
        await uploadTask.whenComplete(() => {});
    await tasksnapshot.ref.getDownloadURL().then((urlImage) {
      downloadUrl = urlImage;
    });
    return downloadUrl;
  }

  savereclamationDataToFirestore(id, downloadUrl, currentFirebaseUser,
      description, service, adresse, cible, uidDemandeur, phone) async {
    await FirebaseFirestore.instance.collection("Reclamation").doc(id).set({
      "ID": id,
      "Demandeur": currentFirebaseUser,
      "Uid_demandeur": uidDemandeur,
      'Description': description,
      'Titre': service,
      'Localisation': adresse,
      'Cible': cible,
      'Image': downloadUrl,
      'Statut': "En attente",
      'Date': Timestamp.now(),
      'Commentaire': '',
      'Phone': phone,
    });
  }

  final CollectionReference reclamationList =
      FirebaseFirestore.instance.collection('profileInfo');

  Future getreclamationList() async {
    List itemsList = [];
    try {
      return itemsList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> checkIfAlreadySubmit(String demandeId) async {
    try {
      final querySnapshot = await _firestore
          .collection('Reclamation')
          .where('ID', isEqualTo: demandeId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking approval status: $error');
      rethrow;
    }
  }

  Future<List<String>> getAutorityTokensByCible(String cible) async {
    List<String> tokens = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Autorite')
          .where('Nom', isEqualTo: cible)
          .get();

      for (var doc in querySnapshot.docs) {
        // Check if 'Nom' in 'Actualite' collection equals 'cible'
        QuerySnapshot autoriteSnapshot =
            await doc.reference.collection('Token').get();

        if (autoriteSnapshot.docs.isNotEmpty) {
          QuerySnapshot tokenSnapshot =
              await doc.reference.collection('Token').get();
          for (var tokenDoc in tokenSnapshot.docs) {
            if (tokenDoc['fcmToken'] != null) {
              tokens.add(tokenDoc['fcmToken']);
            }
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des tokens FCM : $e');
    }
    print("riadh$tokens");
    return tokens;
  }

  Future<void> sendNotificationToAutority(
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
      print("bilel$token");
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

  Future<void> saveNotificationAutority(
      String cible, String title, String description) async {
    try {
      // Récupérer l'ID du document dans la collection "Autorite" où le champ "Nom" correspond à "cible"
      QuerySnapshot autoritesSnapshot = await FirebaseFirestore.instance
          .collection('Autorite')
          .where('Nom', isEqualTo: cible)
          .get();

      if (autoritesSnapshot.docs.isNotEmpty) {
        // Utiliser le premier document trouvé
        String autoriteId = autoritesSnapshot.docs[0].id;
        print(autoriteId);
        // Accéder à la sous-collection "Notification" de l'autorité correspondante et ajouter la notification
        await FirebaseFirestore.instance
            .collection('Autorite')
            .doc(autoriteId)
            .collection('Notification')
            .add({
          'title': title,
          'body': description,
          'timestamp': Timestamp.now(),
        });

        print(
            'Notification enregistrée avec succès dans la sous-collection "Notification" de l\'autorité.');
      } else {
        print('Aucune autorité trouvée avec le nom $cible.');
      }
    } catch (e) {
      print('Erreur lors de l\'enregistrement de la notification: $e');
    }
  }
}
