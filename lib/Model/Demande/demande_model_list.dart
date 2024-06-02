class DemandeModelList {
  final String id;
  final String service;
  final String description;
  final String image;
  final String adresse;
  final String phone;
  final String status;
  final String demandeur;
  final String uid_demandeur;
  final String cible;
  bool isUrgent;
  bool is_submit;
  String is_statut;
  int numberOfApprovals;
  final DateTime date;

  DemandeModelList({
    required this.id,
    required this.service,
    required this.description,
    required this.image,
    required this.adresse,
    required this.phone,
    required this.status,
    required this.demandeur,
    required this.uid_demandeur,
    required this.cible,
    required this.isUrgent,
    required this.is_submit,
    required this.is_statut,
    this.numberOfApprovals = 0, // Valeur par défaut
    required this.date,
  });
}
