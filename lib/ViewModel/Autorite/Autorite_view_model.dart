import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pubfix/Model/Autorite/Autorite_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<autoritemodellist?> getAutoriteByName(String name) async {
    try {
      final querySnapshot = await _firestore
          .collection('Autorite')
          .where('Nom', isEqualTo: name)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return autoritemodellist(
          id: doc.id,
          nom: doc['Nom'],
          email: doc['Email'],
          image: doc['Image'],
          password: doc['Password'],
          phone: doc['Phone'],
        );
      } else {
        return null; // Autorite with the given name not found
      }
    } catch (e) {
      print('Error retrieving autorite by name: $e');
      return null;
    }
  }
}
