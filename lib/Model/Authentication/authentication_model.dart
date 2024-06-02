import 'package:cloud_firestore/cloud_firestore.dart';

class UsersModel {
  final String id;
  final String nom;
  final String email;
  final String photo;
  final String adresse;
  final String password;
  final String phone;

  const UsersModel({
    required this.id,
    required this.nom,
    required this.email,
    required this.photo,
    required this.adresse,
    required this.password,
    required this.phone,
  });

  factory UsersModel.fromDocument(DocumentSnapshot doc) {
    return UsersModel(
        id: doc.id,
        nom: doc['name'],
        email: doc['email'],
        photo: doc['photo'],
        adresse: doc['adresse'],
        password: doc['password'],
        phone: doc['phone']);
  }
}

/*
class DemandeModel {
  final String titre;
  final String description;
  final String image;
  final String adresse;
  final String status;
  final String demandeur;

  DemandeModel(
      {required this.titre,
      required this.description,
      required this.image,
      required this.adresse,
      required this.status,
      required this.demandeur});

  factory DemandeModel.fromJson(Map<String, dynamic> json) {
    return DemandeModel(
      titre: json['title'],
      description: json['description'],
      image: json['urlToImage'],
      adresse: json['adresse'],
      status: json['status'],
      demandeur: json['demandeur'],
    );
  }
}

class DetailsPage extends StatelessWidget {
  final DemandeModel actualite;

  const DetailsPage({super.key, required this.actualite});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(actualite.titre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(actualite.image),
            const SizedBox(height: 16.0),
            Text(actualite.description),
          ],
        ),
      ),
    );
  }
}
*/