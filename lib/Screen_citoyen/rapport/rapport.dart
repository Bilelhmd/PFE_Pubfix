import 'package:flutter/material.dart';
import 'package:pubfix/Screen_citoyen/rapport/liste_encours.dart';
import 'package:pubfix/Screen_citoyen/rapport/liste_ferme.dart';
import 'package:pubfix/Screen_citoyen/rapport/liste_ouvert.dart';
import 'package:pubfix/Screen_citoyen/rapport/ma_liste.dart';
import 'package:pubfix/global/global_instances.dart';

import 'liste_totale.dart';

class Rapports extends StatefulWidget {
  const Rapports({super.key});

  @override
  State<Rapports> createState() => _RapportsState();
}

class _RapportsState extends State<Rapports> {
  final List<String> _options = [
    "En attente",
    "En cours",
    "Clôturées",
    "Mes demandes"
  ];
  //final Widget _content = Container();
  final List<Widget> _widgets = [
    const DetailRapport(),
    const ListeOuvert(),
    const ListeFerme(),
    const ListeEnCours(),
    const MesReclamations()
  ];
  int _currentIndex = 0;
  int? _selectedIndex = 0;
  void _updateContent(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = 4;
    authVM.buildProfileAvatar();

    // bool isPressed = true;
  }

  @override
  Widget build(BuildContext context) {
    // Hauteur totale de l'écran
    double totalHeight = MediaQuery.of(context).size.height;

    // Hauteur de l'AppBar
    double appBarHeight = kToolbarHeight;

    // Hauteur du BottomAppBar (vous pouvez définir une hauteur spécifique si nécessaire)
    double bottomAppBarHeight = 61.0; // Hauteur par défaut pour BottomAppBar

    // Hauteur disponible
    double availableHeight = totalHeight - appBarHeight - bottomAppBarHeight;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromARGB(255, 14, 189, 148),
          title: const Text(
            'Demandes',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
              ), // Icône de notification
              onPressed: () {
                // Action à effectuer lors de l'appui sur l'icône de notification
              },
            ),
            SizedBox(
              height: 40,
              width: 40,
              child: authVM.buildProfileAvatar(),
            ),
            const SizedBox(
              width: 15,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Wrap(
                        spacing: 5.0,
                        children: List<Widget>.generate(
                          _options.length,
                          (index) {
                            return ChoiceChip(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              selectedColor: Colors.greenAccent,
                              label: Text(_options[index]),
                              selected: _selectedIndex == index,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedIndex = index;
                                  } else {
                                    _selectedIndex = null;
                                    _updateContent(
                                        0); // Redirection vers la page DetailRapport lorsque tous les choix sont désélectionnés
                                  }
                                });
                                // Redirection selon le choix sélectionné
                                if (selected) {
                                  switch (_options[index]) {
                                    case 'En attente':
                                      _updateContent(1);
                                      break;
                                    case 'En cours':
                                      _updateContent(2);
                                      break;
                                    case 'Clôturées':
                                      _updateContent(3);
                                      break;
                                    case 'Mes reclamations':
                                      _updateContent(4);
                                      break;
                                    default:
                                      //    _updateContent(index);
                                      break;
                                  }
                                }
                              },
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: availableHeight - 106,
                  //  height: MediaQuery.of(context).size.height * .7,
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _widgets,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
