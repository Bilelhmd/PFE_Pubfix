import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ReportViewModel {
  // DateTime now = DateTime.now(); // Get the current date and time

  //validateDemandeForm(File? imageXFile, String service, String description,String adresse, String cible) async {
  validateDemandeForm(File? imageXFile, String UserName, String adresse,
      String service, String cible, String description) async {
    // Timestamp timestamp = Timestamp.fromDate(now);
    /* if (service.isNotEmpty &&
        description.isNotEmpty &&
        adresse.isNotEmpty &&
        cible.isNotEmpty &&
        imageXFile != null) {*/
    User? currentFirebaseUser = FirebaseAuth.instance.currentUser;
    String downloadUrl = await UploadImageToStorage(imageXFile);
    await saveDemandeDataToFirestore(
        currentFirebaseUser, downloadUrl, service, description, adresse, cible);

    //await saveDemandeDataToFirestore(downloadUrl, UserName, description, service, adresse, cible);
    //await soumettre(downloadUrl, currentFirebaseUser, description, service, adresse, cible);
    //  }
  }

  UploadImageToStorage(File? imageXFile) async {
    try {
      String downloadUrl = "";

      String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      fStorage.Reference storageRef = fStorage.FirebaseStorage.instance
          .ref()
          .child("RapportsImages")
          .child(fileName);
      fStorage.UploadTask uploadTask =
          storageRef.putFile(File(imageXFile!.path));
      fStorage.TaskSnapshot tasksnapshot =
          await uploadTask.whenComplete(() => {});
      await tasksnapshot.ref.getDownloadURL().then((urlImage) {
        downloadUrl = urlImage;
      });
      return downloadUrl;
    } catch (error) {
      print('Erreur Firebase Storage riadh: $error');
      // Gérer l'erreur de manière appropriée, par exemple afficher un message à l'utilisateur
    }
  }

  saveDemandeDataToFirestore(downloadUrl, currentFirebaseUser, description,
      service, adresse, cible) async {
    FirebaseFirestore.instance.collection("Demandes").add({
      "Demandeur": currentFirebaseUser,
      'Description': description,
      'Service': service,
      'Adresse': adresse,
      'Cible': cible,
      'Image': downloadUrl,
      'Status': "Ouvert",
    });
  }

  final CollectionReference demandeList =
      FirebaseFirestore.instance.collection('profileInfo');

  Future getDemandeList() async {
    List itemsList = [];

    try {
      //   await demandeList.getDocuments().then((querySnapshot) {querySnapshot.documents.forEach((element) {itemsList.add(element.data);});
      //  });
      return itemsList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Stream<QuerySnapshot> getDemandes({String? searchQuery}) async* {
    var demandesQuery = FirebaseFirestore.instance
        .collection("Demandes") // Accède à la collection "users"
        .orderBy("Status"); // Ordre les documents par le champ "name"

    // Récupère les snapshots de la requête des contacts
    var demandes = demandesQuery.snapshots();
    yield* demandes;
  }

  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('Demandes');
  Future<void> fetchDemandes() async {
    QuerySnapshot querySnapshot = await _collectionRef.get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    print(allData);

    /*final demandesQuery = FirebaseFirestore.instance
        .collection("Demandes")
        .where("Status", isEqualTo: "Ouvert")
        .get()
        .then(
      (querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          print('${docSnapshot.id} => ${docSnapshot.data()}');
        }
      },
      onError: (e) => print("Error completing: $e"),
    );*/
  }

  Future<void> soumettre(
      File? fileXimage,
      String currentFirebaseUserId,
      String email,
      String description,
      String service,
      String adresse,
      String cible,
      String uid,
      DateTime date,
      String phone) async {
    String? currentToken = await FirebaseMessaging.instance.getToken();

    // Utilisez le paramètre currentFirebaseUserId plutôt que de redéfinir currentFirebaseUser
    String downloadUrl = await UploadImageToStorage(fileXimage);

    Map<String, dynamic> data = {
      'Image': downloadUrl,
      'Demandeur': currentFirebaseUserId,
      'Email': email, // Utilisez le paramètre fourni
      'Adresse': adresse,
      'Service': service,
      'Cible': cible,
      'Description': description,
      'Status': "En attente",
      'Date': date,
      'fcmToken': currentToken,
      'Uid_demandeur': uid,
      'Phone': phone,
    };

    await FirestoreService().saveData(data);
  }

//METHODE POUR AFFICHER LES ADRESSES DE RECLAMATIONS SUR LA CARTE MAPS
  Future<void> fetchAndMarkAddress(Set<Marker> Markeur) async {
    try {
      // Récupérer les données depuis Firestore
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Demandes').get();

      // Traiter les données récupérées
      querySnapshot.docs.forEach((doc) async {
        String address = doc['Adresse'];

        // Convertir l'adresse en coordonnées géographiques
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          Location location = locations.first;
          LatLng position = LatLng(location.latitude, location.longitude);

          // Afficher le marqueur sur la carte
          //  setState(() {
          final marker = Marker(
            markerId: MarkerId(position.toString()),
            position: position,
            infoWindow: InfoWindow(
              title: doc['Service'],
              snippet: doc['Description'],
            ),
          );
          Markeur.add(marker);
          //  }
          // );
        }
      });
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
      await _db.collection('Demandes').add(data);
      print("Données ajoutées avec succès");
    } catch (e) {
      print("Erreur lors de l'ajout de données: $e");
      // Gérer l'erreur
    }
  }
}
