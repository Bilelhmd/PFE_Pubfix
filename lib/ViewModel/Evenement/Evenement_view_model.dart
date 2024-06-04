import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pubfix/Model/Evenement/Evenement_model.dart';
import 'package:pubfix/global/global_var.dart';

class EvenementViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Evenement> _evenements = [];

  List<Evenement> get evenement => _evenements;

  Future<void> loadEvenement() async {
    try {
      final collectionRef = _firestore.collection('Evenement');
      final querySnapshot = await collectionRef.get();

      _evenements = querySnapshot.docs.map((doc) {
        return Evenement(
          id: doc.id,
          titre: doc['Titre'],
          description: doc['Description'],
          image: doc['Image'],
          lieu: doc['Lieu'],
          date: timestampToDateTime(doc['Date']),
          organisateur: doc['Organisateur'],
        );
      }).toList();

      notifyListeners(); // Notifie les auditeurs du changement
    } catch (e) {
      print("Erreur lors du chargement des evenements: $e");
    }
  }

  Future<Map<String, dynamic>?> loadEvenementById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection('Evenement').doc(id).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        print("Aucune événement trouvée avec l'ID $id");
        return null;
      }
    } catch (e) {
      print("Erreur lors du chargement de l'événement avec l'ID $id: $e");
      return null;
    }
  }

  DateTime timestampToDateTime(Timestamp timestamp) {
    return timestamp.toDate();
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Méthode pour supprimer une evenement de Firebase
  Future<void> deleteEvenement1(String id) async {
    try {
      // Supprimez le document correspondant à l'ID donné de la collection "evenement"
      await _firestore.doc(id).delete();

      // Rechargez les evenements après la suppression
      await loadEvenement();
    } catch (e) {
      print("Erreur lors de la suppression de l'evenement: $e");
    }
  }

  Future<void> deleteEvenement(String id) async {
    try {
      // Référence à la réclamation dans la base de données
      final evenementRef = _firestore.collection('Evenement').doc(id);

      // Supprimer la réclamation
      await evenementRef.delete();
      print('evenement supprimée avec succès.');
    } catch (error) {
      print('Erreur lors de la suppression de la evenement : $error');
      throw error;
    }
  }

  Future<void> updateEvenement(String id, String titre, String description,
      Timestamp date, String autorite, String lieu) async {
    try {
      // Référence au document de l'evenement dans Firestore
      final evenementRef = _firestore.collection('Evenement').doc(id);

      // Mise à jour des champs de l'evenement
      await evenementRef.update({
        'Titre': titre,
        'Description': description,
        'Autorite': autorite,
        'Date': date, // Stocker le timestamp
        'Lieu': lieu,
      });

      // Mettre à jour localement la liste des evenements
      final index = _evenements.indexWhere((evenement) => evenement.id == id);
      if (index != -1) {
        _evenements[index] = Evenement(
          id: id,
          titre: titre,
          description: description,
          organisateur: autorite,
          lieu: lieu,
          image: _evenements[index].image,
          date: timestampToDateTime(date), // Convertir le timestamp en DateTime
        );
        notifyListeners(); // Notifie les auditeurs du changement
      }
    } catch (e) {
      print("Erreur lors de la mise à jour de l'evenement: $e");
    }
  }

  Future<List<Evenement>> getEvenement() async {
    // Create a reference to your collection
    const List<Evenement> texte = [];
    try {
      final collectionRef =
          _firestore.collection('Evenement').orderBy('Date', descending: true);
      final querySnapshot = await collectionRef.get();

      // Convert documents to DemandeModelList objects
      final evenement = querySnapshot.docs.map((doc) {
        return Evenement(
          id: doc.id,
          titre: doc['Titre'],
          description: doc['Description'],
          image: doc['Image'],
          lieu: doc['Lieu'],
          date: timestampToDateTime(doc['Date']),
          organisateur: doc['Organisateur'],
        );
      }).toList();

      return evenement;
    } catch (e) {
      print(e);
    }
    return texte;
  }

  Future<bool> checkIfAlreadyParticipate(
      String evenementId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('Evenement')
          .doc(evenementId)
          .collection('Participation')
          .where('id_user', isEqualTo: userId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking participate: $error');
      rethrow;
    }
  }

  Future<void> addParticipationDocument(String evenementId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }
      final currentDate = DateTime.now();
      // Reference to the subcollection 'participation' under the document with demandeId
      final docRef = _firestore
          .collection('Evenement')
          .doc(evenementId)
          .collection('Participation')
          .doc();

      // Add a new document with a generated ID
      await docRef.set({
        'id_participant': user.uid,
        'Nom_participant': sharefPrefrences!.getString("name").toString(),
        'Date': currentDate,
      });
    } catch (error) {
      print('Error adding participation document: $error');
      rethrow;
    }
  }

  Future<int> getParticipantCount(String evenementId) async {
    final querySnapshot = await _firestore
        .collection('Evenement')
        .doc(evenementId)
        .collection('Participation')
        .get();
    return querySnapshot.docs.length;
  }
}
