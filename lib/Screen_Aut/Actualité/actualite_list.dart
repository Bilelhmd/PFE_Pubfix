import 'package:flutter/material.dart';
import 'package:pubfix/Model/Actualite/Actualite_model.dart';
import 'package:pubfix/Screen_Aut/Actualit%C3%A9/ajoutactualite.dart';
import 'package:pubfix/Screen_Aut/Actualit%C3%A9/edit_actualite.dart';
import 'package:pubfix/ViewModel/Actualite/ActualiteViewModel.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

class actualite_list extends StatefulWidget {
  const actualite_list({super.key});

  @override
  _actualite_listState createState() => _actualite_listState();
}

class _actualite_listState extends State<actualite_list> {
  final ActualiteViewModel _actualiteViewModel = ActualiteViewModel();
  bool _isLoading = true;
  Map<String, dynamic>? _actualiteData;

  Evenement? _selectedActualite;
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await _actualiteViewModel.loadActualites();
      setState(() {
        _isLoading =
            false; // Met à jour l'état pour indiquer que le chargement est terminé
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> _loadActualiteById(String id) async {
    final actualiteData = await _actualiteViewModel.loadActualiteById(id);
    if (actualiteData != null) {
      setState(() {
        _actualiteData = actualiteData;
        _selectedActualite = _actualiteViewModel.actualites
            .firstWhere((actualite) => actualite.id == id);
      });
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(imageUrl),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Fermer',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Actualités",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.bold, // Taille de police réduite
          ),
        ),
        backgroundColor: const Color(0xff05B068),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment
                  .stretch, // Étire les enfants pour correspondre à la largeur
              children: [
                SizedBox(
                  height: 250,
                  child: ScrollSnapList(
                    itemBuilder: _buildListItem,
                    itemCount: _actualiteViewModel.actualites.length,
                    itemSize: 150,
                    onItemFocus: (index) {
                      // Charger les données de l'actualité sélectionnée
                      _loadActualiteById(
                          _actualiteViewModel.actualites[index].id);
                    },
                    dynamicItemSize: true,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                            height: 20.0), // Espacement avant les champs

                        // Affichage des champs d'actualité
                        _buildField(
                            "Autorite", _actualiteData?['Autorite'] ?? ""),
                        _buildField("Titre", _actualiteData?['Titre'] ?? ""),
                        _buildField(
                            "Date",
                            _actualiteData != null
                                ? _actualiteViewModel.formatDate(
                                    _actualiteViewModel.timestampToDateTime(
                                        _actualiteData!['Date']))
                                : ""),
                        _buildField("Description",
                            _actualiteData?['Description'] ?? ""),
                        _buildField("Localisation",
                            _actualiteData?['Localisation'] ?? ""),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _selectedActualite != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditActualite(
                            actualite:
                                _selectedActualite!), // Rediriger vers le formulaire d'édition
                      ),
                    ).then((result) {
                      if (result == true) {
                        _fetchData(); // Rafraîchir les données si une actualité a été modifiée
                      }
                    });
                  }
                : null, // Icône du bouton
            backgroundColor: const Color.fromARGB(255, 203, 244, 54),
            child: const Icon(Icons.edit), // Couleur de fond du bouton
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _selectedActualite != null
                ? () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirmation"),
                          content: const Text(
                              "Voulez-vous vraiment supprimer cette actualité ?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                    context); // Ferme la boîte de dialogue
                              },
                              child: const Text("Annuler"),
                            ),
                            TextButton(
                              onPressed: () {
                                _actualiteViewModel
                                    .deleteActualite(_selectedActualite!.id);
                                Navigator.pop(
                                    context); // Ferme la boîte de dialogue
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const actualite_list()),
                                );
                              },
                              child: const Text("Supprimer"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                : null,
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete),
          ),

          const SizedBox(width: 16), // Espacement entre les boutons
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Add_Actualite()),
              );
            }, // Icône du bouton
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add), // Couleur de fond du bouton
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Position du bouton (en bas à droite)
    );
  }

  // Widget pour afficher les champs d'actualité
  Widget _buildField(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              const SizedBox(height: 3.0),
              Text(
                value,
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    Evenement actualite = _actualiteViewModel.actualites[index];
    return Container(
      width: 150,
      height: 300,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10.0)),
                  image: DecorationImage(
                    image: NetworkImage(
                      actualite.image,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actualite.titre,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility,
                            size: 24, color: Colors.blue),
                        color: Colors.blue,
                        onPressed: () {
                          _showImageDialog(actualite.image);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
