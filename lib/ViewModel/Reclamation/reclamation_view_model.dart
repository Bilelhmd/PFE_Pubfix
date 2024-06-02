import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pubfix/Model/Autorite/Autorite_model.dart';
import 'package:pubfix/Model/Reclamation/Reclamation_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<reclamationModelList>> getreclamations() async {
    // Create a reference to your collection
    final collectionRef = _firestore.collection(
        'Reclamation'); // Replace 'reclamations' with your actual collection name

    // Get the query snapshot
    final querySnapshot = await collectionRef.get();

    // Convert documents to reclamationModelList11 objects
    final reclamations = querySnapshot.docs.map((doc) {
      return reclamationModelList(
        id: doc.id,
        titre: doc['Titre'],
        description: doc['Description'],
        image: doc['Image'],
        date: doc['Date'],
        statut: doc['Statut'],
        demandeur: doc['Demandeur'],
        cible: doc['Cible'],
        phone: doc['Phone'],
        localisation: doc['Localisation'],
        commentaire: doc['Commentaire'],
        uid_demandeur: doc['Uid_demandeur'],
      );
    }).toList();

    return reclamations;
  }

  Future<List<reclamationModelList>> getreclamationsbyUser(
      User? username) async {
    // Create a reference to your collection
    final collectionRef = _firestore.collection(
        'Reclamation'); // Replace 'reclamations' with your actual collection name

    // Build the query based on desiredStatut
    Query query = collectionRef.where("Cible", isEqualTo: username);

    final querySnapshot = await query.get();

    // Convert documents to reclamationModelList1 objects
    final reclamations = querySnapshot.docs.map((doc) {
      return reclamationModelList(
        id: doc.id,
        titre: doc['Titre'],
        description: doc['Description'],
        image: doc['Image'],
        date: doc['Date'],
        statut: doc['Statut'],
        demandeur: doc['Demandeur'],
        cible: doc['Cible'],
        phone: doc['Phone'],
        localisation: doc['Localisation'],
        commentaire: doc['Commentaire'],
        uid_demandeur: doc['Uid_demandeur'],
      );
    }).toList();

    return reclamations;
  }

  Future<List<String>> getUserTokensByIddemandeur(String idDemandeur) async {
    List<String> tokens = [];
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(idDemandeur)
          .get();
      if (docSnapshot.exists) {
        // Obtenir les documents de la sous-collection 'Token' pour cet utilisateur
        QuerySnapshot tokenSnapshot =
            await docSnapshot.reference.collection('Token').get();

        // Parcourir chaque document de la sous-collection 'Token'
        for (var tokenDoc in tokenSnapshot.docs) {
          // Ajouter le fcmToken à la liste si non null
          if (tokenDoc['fcmToken'] != null) {
            tokens.add(tokenDoc['fcmToken']);
          }
        }
      } else {
        print('Aucun document trouvé pour id_demandeur: $idDemandeur');
      }
    } catch (e) {
      print('Erreur lors de la récupération des tokens FCM : $e');
    }
    print("Tokens récupérés: $tokens");
    return tokens;
  }

  Future<void> updateReclamationStatut(
      String reclamationId,
      String reclamationTitre,
      String reclamationuidDemandeur,
      String newStatus,
      String comment) async {
    try {
      // Référence à la réclamation dans la base de données
      final reclamationRef =
          _firestore.collection('Reclamation').doc(reclamationId);

      // Mettre à jour le statut de la réclamation
      await reclamationRef.update({
        'Statut': newStatus,
        'Commentaire': comment, // Ajouter le commentaire à la mise à jour
      });
      List<String> tokens =
          await getUserTokensByIddemandeur(reclamationuidDemandeur);
      print(reclamationuidDemandeur);
      await sendNotificationToAutority(reclamationTitre, newStatus, tokens);
      await saveNotificationAutority(reclamationTitre, newStatus);
      print('Réclamation mis a jour avec succès.');
    } catch (error) {
      print(
          'Erreur lors de la mise à jour du statut de la réclamation : $error');
      rethrow;
    }
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
      String title, String description) async {
    try {
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

  Future<void> deleteReclamation(String reclamationId) async {
    try {
      // Référence à la réclamation dans la base de données
      final reclamationRef =
          _firestore.collection('Reclamation').doc(reclamationId);

      // Supprimer la réclamation
      await reclamationRef.delete();
      print('Réclamation supprimée avec succès.');
    } catch (error) {
      print('Erreur lors de la suppression de la réclamation : $error');
      rethrow;
    }
  }

  Future<List<reclamationModelList>> getReclamationsByAutorite() async {
    try {
      final autorite = await getautoriteconnecte();
      if (autorite.isNotEmpty) {
        final querySnapshot = await _firestore
            .collection('Reclamation')
            .where('Cible', isEqualTo: autorite)
            .get();

        final reclamations = querySnapshot.docs.map((doc) {
          return reclamationModelList(
            id: doc.id,
            titre: doc['Titre'],
            description: doc['Description'],
            image: doc['Image'],
            date: timestampToDateTime(doc['Date']),
            statut: doc['Statut'],
            demandeur: doc['Demandeur'],
            cible: doc['Cible'],
            phone: doc['Phone'],
            localisation: doc['Localisation'],
            commentaire: doc['Commentaire'],
            uid_demandeur: doc['Uid_demandeur'],
          );
        }).toList();

        return reclamations;
      } else {
        // Gérer le cas où aucun nom d'autorité n'est trouvé
        print('Aucun nom d\'autorité trouvé.');
        return [];
      }
    } catch (e) {
      print('Error retrieving reclamations by autorite: $e');
      return [];
    }
  }

  Future<List<autoritemodellist>> getautorites() async {
    // Create a reference to your collection
    final collectionRef = _firestore.collection(
        'Autorite'); // Replace 'Autorites' with your actual collection name

    // Get the query snapshot
    final querySnapshot = await collectionRef.get();

    // Convert documents to autoritemodellist objects
    final autorites = querySnapshot.docs.map((doc) {
      return autoritemodellist(
        id: doc.id,
        nom: doc['Nom'],
        email: doc['Email'],
        image: doc['Image'],
        password: doc['Password'],
        phone: doc['Phone'],
      );
    }).toList();

    return autorites;
  }

  Future<String> getautoriteconnecte() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final datasnapshot = await FirebaseFirestore.instance
            .collection("Autorite")
            .doc(user.uid)
            .get();
        if (datasnapshot.exists) {
          // Retourner le nom de l'autorité connectée
          return datasnapshot.data()?['Nom'] ?? '';
        } else {
          print("Aucune autorité trouvée pour l'utilisateur connecté.");
          return '';
        }
      } else {
        print("Aucun utilisateur connecté.");
        return '';
      }
    } catch (error) {
      print('Erreur lors de la récupération de l\'autorité connectée: $error');
      return '';
    }
  }

  DateTime timestampToDateTime(Timestamp timestamp) {
    return timestamp.toDate();
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
