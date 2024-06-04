import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pubfix/Model/Actualite/Actualite_model.dart';

class ActualiteViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Evenement> _actualites = [];

  List<Evenement> get actualites => _actualites;

  Future<void> loadActualites() async {
    try {
      final collectionRef = _firestore.collection('Actualite');
      final querySnapshot = await collectionRef.get();

      _actualites = querySnapshot.docs.map((doc) {
        return Evenement(
          id: doc.id,
          titre: doc['Titre'],
          description: doc['Description'],
          image: doc['Image'],
          localisation: doc['Localisation'],
          date: timestampToDateTime(doc['Date']),
          autorite: doc['Autorite'],
        );
      }).toList();

      notifyListeners(); // Notifie les auditeurs du changement
    } catch (e) {
      print("Erreur lors du chargement des actualités: $e");
    }
  }

  Future<Map<String, dynamic>?> loadActualiteById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection('Actualite').doc(id).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        print("Aucune actualité trouvée avec l'ID $id");
        return null;
      }
    } catch (e) {
      print("Erreur lors du chargement de l'actualité avec l'ID $id: $e");
      return null;
    }
  }

  DateTime timestampToDateTime(Timestamp timestamp) {
    return timestamp.toDate();
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Méthode pour supprimer une actualité de Firebase
  Future<void> deleteActualite1(String id) async {
    try {
      // Supprimez le document correspondant à l'ID donné de la collection "Actualite"
      await _firestore.doc(id).delete();

      // Rechargez les actualités après la suppression
      await loadActualites();
    } catch (e) {
      print("Erreur lors de la suppression de l'actualité: $e");
    }
  }

  Future<void> deleteActualite(String id) async {
    try {
      // Référence à la réclamation dans la base de données
      final actualiteRef = _firestore.collection('Actualite').doc(id);

      // Supprimer la réclamation
      await actualiteRef.delete();
      print('Actualité supprimée avec succès.');
    } catch (error) {
      print('Erreur lors de la suppression de la actualité : $error');
      throw error;
    }
  }

  Future<void> updateActualite(String id, String titre, String description,
      Timestamp date, String autorite, String localisation) async {
    try {
      // Référence au document de l'actualité dans Firestore
      final actualiteRef = _firestore.collection('Actualite').doc(id);

      // Mise à jour des champs de l'actualité
      await actualiteRef.update({
        'Titre': titre,
        'Description': description,
        'Autorite': autorite,
        'Date': date, // Stocker le timestamp
        'Localisation': localisation,
      });

      // Mettre à jour localement la liste des actualités
      final index = _actualites.indexWhere((actualite) => actualite.id == id);
      if (index != -1) {
        _actualites[index] = Evenement(
          id: id,
          titre: titre,
          description: description,
          autorite: autorite,
          localisation: localisation,
          image: _actualites[index].image,
          date: timestampToDateTime(date), // Convertir le timestamp en DateTime
        );
        notifyListeners(); // Notifie les auditeurs du changement
      }
    } catch (e) {
      print("Erreur lors de la mise à jour de l'actualité: $e");
    }
  }

  Future<List<Evenement>> getActualites() async {
    // Create a reference to your collection
    const List<Evenement> texte = [];
    try {
      final collectionRef =
          _firestore.collection('Actualite').orderBy('Date', descending: true);
      final querySnapshot = await collectionRef.get();

      // Convert documents to DemandeModelList objects
      final actualite = querySnapshot.docs.map((doc) {
        return Evenement(
          id: doc.id,
          titre: doc['Titre'],
          description: doc['Description'],
          image: doc['Image'],
          localisation: doc['Localisation'],
          date: timestampToDateTime(doc['Date']),
          autorite: doc['Autorite'],
        );
      }).toList();

      return actualite;
    } catch (e) {
      print(e);
    }
    return texte;
  }
}
