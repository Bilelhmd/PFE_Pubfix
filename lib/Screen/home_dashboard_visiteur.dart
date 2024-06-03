import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pubfix/Screen_citoyen/Actualite/liste_actualite.dart';
import 'package:pubfix/Screen_citoyen/dashboard/dashboard.dart';
import 'package:pubfix/Screen_citoyen/profile/account_screen.dart';
import 'package:pubfix/Screen_citoyen/rapport/demande.dart';
import 'package:pubfix/Screen_citoyen/rapport/rapport.dart';
import 'package:pubfix/Screen_visiteur/dashboard/dashboard.dart';

class Home_Visiteur extends StatefulWidget {
  final int initialTabIndex;

  const Home_Visiteur({super.key, this.initialTabIndex = 0});

  @override
  State<Home_Visiteur> createState() => _Home_VisiteurState();
}

class _Home_VisiteurState extends State<Home_Visiteur> {
  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Selectionner votre choix'),
        message: const Text('Ajouter une reclamation ou évènement bénévole '),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would be a default
            /// default behavior, turns the action's text to bold text.
            isDefaultAction: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DemandeReclamation(),
                ),
              );
            },
            child: const Text(
              'Ajouter une reclamation',
              style: TextStyle(
                color: Color.fromARGB(255, 16, 130, 58),
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Ajouter un évènement bénévole',
              style: TextStyle(
                color: Color.fromARGB(255, 25, 120, 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  late int _currentTabIndex;

  final List<Widget> _pages = [
    const Dashboard(),
    const Rapports(),
    const ListeActualite(),
    const AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Dashboard_Visiteur());
  }

  Widget _buildBottomNavigationBarItem(IconData icon, String label, int index) {
    return MaterialButton(
      onPressed: () => _onTabTapped(index),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _currentTabIndex == index
                  ? const Color.fromRGBO(0, 117, 117, 1)
                  : Colors.white,
              //   color: _currentTabIndex == index ? Colors.black : Colors.white,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: _currentTabIndex == index
                    ? const Color.fromRGBO(0, 117, 117, 1)
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
