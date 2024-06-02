class reclamationModelList {
  final String id;
  final String titre;
  final String description;
  final String image;
  final String localisation;
  final String phone;
  final String statut;
  final String demandeur;
  final String uid_demandeur;
  final String cible;
  final DateTime date;
  final String commentaire;

  const reclamationModelList({
    required this.id,
    required this.titre,
    required this.description,
    required this.image,
    required this.localisation,
    required this.statut,
    required this.phone,
    required this.demandeur,
    required this.uid_demandeur,
    required this.cible,
    required this.date,
    required this.commentaire,
  });
}
