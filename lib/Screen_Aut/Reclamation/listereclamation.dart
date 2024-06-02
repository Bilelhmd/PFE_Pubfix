import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pubfix/Model/Reclamation/Reclamation_model.dart';
import 'package:pubfix/Screen_Aut/Notification/Notification.dart';
import 'package:pubfix/ViewModel/Reclamation/reclamation_view_model.dart';

class ListeReclamation extends StatefulWidget {
  const ListeReclamation({Key? key}) : super(key: key);

  @override
  _ListeReclamationState createState() => _ListeReclamationState();
}

class _ListeReclamationState extends State<ListeReclamation> {
  bool isFavorite = false;
  bool isExpanded = false;
  String selectedstatut = 'Tous';
  String selectedstatutForEdit = '';
  String commentaire = '';
  final ValueNotifier<bool> _hasNewNotification = ValueNotifier<bool>(false);
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  List<reclamationModelList> _reclamations = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _listenToNotifications();
  }

  Future<void> _fetchData() async {
    try {
      final reclamations = await _firestoreService.getReclamationsByAutorite();
      setState(() {
        _reclamations = reclamations;
      });
    } catch (error) {
      print(error);
    }
  }

  void _listenToNotifications() {
    FirebaseFirestore.instance
        .collection('Autorite')
        .doc(currentUser!
            .uid) // Remplacez USER_ID par l'ID de l'utilisateur actuel
        .collection('Notification')
        .snapshots()
        .listen((snapshot) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null, // Ceci enlève le bouton de retour
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 14, 189, 148),
        elevation: 0.0,
        title: Text(
          'Liste de réclamation',
          style: GoogleFonts.poppins(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _hasNewNotification,
            builder: (context, hasNewNotification, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _hasNewNotification.value = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotificationsPage(userId: currentUser?.uid ?? ''),
                        ),
                      );
                    },
                  ),
                  if (hasNewNotification)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              children: [
                Text(
                  'Filtrer par statut:               $selectedstatut', // Afficher le statut choisi
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.filter_alt_outlined,
                  color: Colors.grey[600],
                ),
              ],
            ),
            collapsedTextColor: Colors.blue,
            iconColor: Colors.blue,
            children: [
              ListTile(
                title: Text('Tous'),
                onTap: () {
                  setState(() {
                    selectedstatut = 'Tous';
                    isExpanded = false;
                  });
                },
                selected: selectedstatut == 'Tous',
              ),
              ListTile(
                title: Text('En attente'),
                onTap: () {
                  setState(() {
                    selectedstatut = 'En attente';
                    isExpanded = false;
                  });
                },
                selected: selectedstatut == 'En attente',
              ),
              ListTile(
                title: Text('En cours'),
                onTap: () {
                  setState(() {
                    selectedstatut = 'En cours';
                    isExpanded = false;
                  });
                },
                selected: selectedstatut == 'En cours',
              ),
              ListTile(
                title: Text('Clôturée'),
                onTap: () {
                  setState(() {
                    selectedstatut = 'Clôturée';
                    isExpanded = false;
                  });
                },
                selected: selectedstatut == 'Clôturée',
              ),
            ],
          ),
          Expanded(
            child: _reclamations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _reclamations.length,
                    itemBuilder: (context, index) {
                      final reclamation = _reclamations[index];
                      if (selectedstatut != 'Tous' &&
                          reclamation.statut != selectedstatut) {
                        return SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () {
                          _showDetailsDialog(context, reclamation);
                        },
                        child: Card(
                          child: ListTile(
                            leading: reclamation.image.isNotEmpty
                                ? Image.network(
                                    reclamation.image,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image_not_supported,
                                    size: 20),
                            title: Text(reclamation.titre),
                            subtitle: Text(
                              reclamation.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: reclamation.statut == 'En attente'
                                        ? Colors.green
                                        : reclamation.statut == 'En cours'
                                            ? Colors.blue
                                            : Colors.red,
                                  ),
                                ),
                                Spacer(),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isFavorite = !isFavorite;
                                    });
                                  },
                                  icon: isFavorite
                                      ? Icon(Icons.favorite, color: Colors.red)
                                      : Icon(Icons.favorite_outline,
                                          color: Colors.red),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(
      BuildContext context, reclamationModelList reclamation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de la réclamation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reclamation.titre,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Image.network(
                reclamation.image,
                height: 150,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 8),
              Text(
                'Description: ${reclamation.description}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Demandé par: ${reclamation.demandeur}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Text(
                    DateFormat.yMMMd().format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Commentaire explicatif: ${reclamation.commentaire}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _showEditDialog(context, reclamation);
            },
            child: Text('Mettre à jour'),
          ),
          ElevatedButton(
            onPressed: () {
              _showDeleteConfirmationDialog(context, reclamation);
            },
            child: Text('Supprimer'),
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, reclamationModelList reclamation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mettre à jour le statut de la réclamation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              title: Text('Statut'),
              children: [
                ListTile(
                  title: Text('En attente'),
                  onTap: () {
                    setState(() {
                      selectedstatutForEdit = 'En attente';
                    });
                  },
                  selected: selectedstatutForEdit == 'En attente',
                ),
                ListTile(
                  title: Text('En cours'),
                  onTap: () {
                    setState(() {
                      selectedstatutForEdit = 'En cours';
                    });
                  },
                  selected: selectedstatutForEdit == 'En cours',
                ),
                ListTile(
                  title: Text('Clôturée'),
                  onTap: () {
                    setState(() {
                      selectedstatutForEdit = 'Clôturée';
                    });
                  },
                  selected: selectedstatutForEdit == 'Clôturée',
                ),
              ],
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Commentaire'),
              onChanged: (value) {
                commentaire = value;
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (selectedstatutForEdit.isNotEmpty) {
                _showConfirmationDialog(
                    context, reclamation, selectedstatutForEdit, commentaire);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Veuillez sélectionner un statut'),
                  duration: Duration(seconds: 2),
                ));
              }
            },
            child: Text('Confirmer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context,
      reclamationModelList reclamation, String newStatut, String commentaire) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le changement de statut'),
        content: const Text(
            'Voulez-vous vraiment mettre à jour le statut de cette réclamation ?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              _firestoreService.updateReclamationStatut(
                  reclamation.id,
                  reclamation.titre,
                  reclamation.uid_demandeur,
                  newStatut,
                  commentaire);
              Navigator.pop(context);
            },
            child: Text('Confirmer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, reclamationModelList reclamation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Êtes-vous sûr de vouloir supprimer cette réclamation ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Supprimer la réclamation
              _firestoreService.deleteReclamation(reclamation.id);
              Navigator.pop(context);
            },
            child: Text('Supprimer'),
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
