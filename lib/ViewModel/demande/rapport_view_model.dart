import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pubfix/Model/Demande/Demande_model.dart';
import 'package:pubfix/Model/Demande/demande_model_list.dart';
import 'package:pubfix/global/global_var.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<DemandeModelList>> getDemandes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }
      // Create a reference to your collection
      final collectionRef = _firestore.collection('Demandes');
      final querySnapshot = await collectionRef.get();

      // Convert documents to DemandeModelList objects
      final List<DemandeModelList> demandes = [];

      // Boucle à travers les documents
      for (final doc in querySnapshot.docs) {
        // Récupérer le nombre d'approbations pour chaque document
        final int numberOfApprovals = await getNumberOfApprovals(doc.id);
// Check if the current user has already approved this demand
        final isApproved = await checkIfAlreadyApproved(doc.id, user.uid);
        final bool isSubmit = await checkIfAlreadySubmit(doc.id);
        // Set is_urgent based on approval status
        final bool isUrgent = isApproved;
        final isStatut = await statutIfAlreadySubmit(doc.id);
        // Ajouter la demande avec le nombre d'approbations à la liste
        demandes.add(DemandeModelList(
          id: doc.id,
          service: doc['Service'],
          description: doc['Description'],
          image: doc['Image'],
          adresse: doc['Adresse'],
          phone: doc['Phone'],
          status: doc['Status'],
          demandeur: doc['Demandeur'],
          uid_demandeur: doc['Uid_demandeur'],
          cible: doc['Cible'],
          numberOfApprovals: numberOfApprovals,
          isUrgent: isUrgent,
          is_submit: isSubmit,
          is_statut: isStatut,
          date: timestampToDateTime(doc['Date']),
        ));
      }

      return demandes;
    } catch (error) {
      print(error);
      return []; // En cas d'erreur, retourne une liste vide
    }
  }

/*
  Future<List<DemandeModel>> getDemandes() async {
    // Create a reference to your collection
    final collectionRef = _firestore.collection('Demandes').orderBy(
        "Service"); // Replace 'demandes' with your actual collection name

    // Get the query snapshot
    final querySnapshot = await collectionRef.get();

    // Convert documents to DemandeModelList objects
    final demandes = querySnapshot.docs.map((doc) {
      return DemandeModel(
        id: doc.id,
        service: doc['Service'],
        description: doc['Description'],
        image: doc['Image'],
        adresse: doc['Adresse'],
        status: doc['Status'],
        demandeur: doc['Demandeur'],
        cible: doc['Cible'],
        date: timestampToDateTime(doc['Date']),
      );
    }).toList();

    return demandes;
  }
*/
  Future<List<DemandeModel>> getDemandesbyStatusOuvert() async {
    // Create a reference to your collection
    final collectionRef = _firestore.collection('Demandes');
    // Build the query based on desiredStatus
    Query query = collectionRef.where("Status", isEqualTo: "En attente");
    /* if (status != null) {
    query = query.where('Status', isEqualTo: status);
  }*/

    // Get the query snapshot
    final querySnapshot = await query.get();

    // Convert documents to DemandeModel objects
    final demandes = querySnapshot.docs.map((doc) {
      return DemandeModel(
        id: doc.id,
        service: doc['Service'],
        description: doc['Description'],
        image: doc['Image'],
        adresse: doc['Adresse'],
        status: doc['Status'],
        demandeur: doc['Demandeur'],
        cible: doc['Cible'],
        date: timestampToDateTime(doc['Date']),
      );
    }).toList();

    return demandes;
  }

  Future<List<DemandeModel>> getDemandesbyStatusEncours() async {
    // Create a reference to your collection
    final collectionRef = _firestore.collection('Demandes');
    // Build the query based on desiredStatus
    Query query = collectionRef.where("Status", isEqualTo: "En cours");

    // Get the query snapshot
    final querySnapshot = await query.get();

    // Convert documents to DemandeModel objects
    final demandes = querySnapshot.docs.map((doc) {
      return DemandeModel(
        id: doc.id,
        service: doc['Service'],
        description: doc['Description'],
        image: doc['Image'],
        adresse: doc['Adresse'],
        status: doc['Status'],
        demandeur: doc['Demandeur'],
        cible: doc['Cible'],
        date: timestampToDateTime(doc['Date']),
      );
    }).toList();

    return demandes;
  }

  Future<List<DemandeModel>> getDemandesbyStatusFerme() async {
    // Create a reference to your collection
    final collectionRef = _firestore.collection(
        'Demandes'); // Replace 'demandes' with your actual collection name

    // Build the query based on desiredStatus
    Query query = collectionRef.where("Status", isEqualTo: "Clôturée");
    /* if (status != null) {
    query = query.where('Status', isEqualTo: status);
  }*/

    // Get the query snapshot
    final querySnapshot = await query.get();

    // Convert documents to DemandeModel objects
    final demandes = querySnapshot.docs.map((doc) {
      return DemandeModel(
        id: doc.id,
        service: doc['Service'],
        description: doc['Description'],
        image: doc['Image'],
        adresse: doc['Adresse'],
        status: doc['Status'],
        demandeur: doc['Demandeur'],
        cible: doc['Cible'],
        date: timestampToDateTime(doc['Date']),
      );
    }).toList();

    return demandes;
  }

  User? currentFirebaseUser = FirebaseAuth.instance.currentUser;

  Future<List<DemandeModel>> getDemandesbyUser() async {
    // Create a reference to your collection
    final collectionRef = _firestore.collection(
        'Demandes'); // Replace 'demandes' with your actual collection name
    String mail = sharefPrefrences!.getString("email").toString();

    // Build the query based on desiredStatus
    Query query = collectionRef.where("email", isEqualTo: mail);
    /* if (status != null) {
    query = query.where('Status', isEqualTo: status);
  }*/

    // Get the query snapshot
    final querySnapshot = await query.get();

    // Convert documents to DemandeModel objects
    final demandes = querySnapshot.docs.map((doc) {
      return DemandeModel(
        id: doc.id,
        service: doc['Service'],
        description: doc['Description'],
        image: doc['Image'],
        adresse: doc['Adresse'],
        status: doc['Status'],
        demandeur: doc['Demandeur'],
        cible: doc['Cible'],
        date: timestampToDateTime(doc['Date']),
      );
    }).toList();

    return demandes;
  }

  // Méthode pour convertir Timestamp en DateTime
  DateTime timestampToDateTime(Timestamp timestamp) {
    return timestamp.toDate();
  }

  // Méthode pour formater une date en chaîne de caractères
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<bool> checkIfAlreadyApproved(String demandeId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('Demandes')
          .doc(demandeId)
          .collection('Approbation')
          .where('id_user', isEqualTo: userId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking approval status: $error');
      rethrow;
    }
  }

// Fonction pour récupérer le nombre de documents dans la sous-collection "Approbation"
  Future<int> getNumberOfApprovals(String demandeId) async {
    try {
      // Référence à la sous-collection "Approbation" pour un document spécifique
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Demandes')
          .doc(demandeId)
          .collection('Approbation')
          .get();

      // Retourne le nombre de documents dans la sous-collection "Approbation"
      return querySnapshot.size;
    } catch (error) {
      print('Error: $error');
      return 0; // En cas d'erreur, retourne 0
    }
  }

  Future<String> statutIfAlreadySubmit(String id) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Reclamation')
          .where('ID', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Aucun document correspondant n'a été trouvé, retourner "En attente"
        return "En attente";
      } else {
        // Des documents correspondants ont été trouvés
        // Extrait le statut du premier document
        final statut = querySnapshot.docs.first.data()['Statut'];
        return statut;
      }
    } catch (error) {
      print('Erreur lors de la vérification du statut de reclamation : $error');
      rethrow;
    }
  }

  checkIfAlreadySubmit(String id) async {
    try {
      final querySnapshot = await _firestore
          .collection('Reclamation')
          .where('ID', isEqualTo: id)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking approval status: $error');
      rethrow;
    }
  }

  Future<void> addApprobationDocument(String demandeId, String appName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }
      final currentDate = DateTime.now();
      // Reference to the subcollection 'Approbation' under the document with demandeId
      final docRef = _firestore
          .collection('Demandes')
          .doc(demandeId)
          .collection('Approbation')
          .doc();

      // Add a new document with a generated ID
      await docRef.set({
        'id_user': user.uid,
        'Appname': sharefPrefrences!.getString("name").toString(),
        'Date': currentDate,
      });
    } catch (error) {
      print('Error adding approbation document: $error');
      rethrow;
    }
  }
}
