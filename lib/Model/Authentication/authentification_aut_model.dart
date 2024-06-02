import 'package:cloud_firestore/cloud_firestore.dart';

class autoritesModel {
  final String id;
  final String nom;
  final String email;
  final String photo;
  final String adresse;
  final String password;
  final String phone;

  const autoritesModel({
    required this.id,
    required this.nom,
    required this.email,
    required this.photo,
    required this.adresse,
    required this.password,
    required this.phone,
  });

  factory autoritesModel.fromDocument(DocumentSnapshot doc) {
    return autoritesModel(
        id: doc.id,
        nom: doc['Nom'],
        email: doc['Email'],
        photo: doc['Image'],
        adresse: doc['Adresse'],
        password: doc['Password'],
        phone: doc['Phone']);
  }
}
