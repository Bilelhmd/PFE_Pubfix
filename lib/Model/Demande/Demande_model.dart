class DemandeModel {
  final String id;
  final String service;
  final String description;
  final String image;
  final String adresse;
  final String status;
  final String demandeur;
  final String cible;
  final DateTime date;

  const DemandeModel({
    required this.id,
    required this.service,
    required this.description,
    required this.image,
    required this.adresse,
    required this.status,
    required this.demandeur,
    required this.cible,
    required this.date,
  });
}
