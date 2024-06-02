import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pubfix/Screen_citoyen/Actualite/liste_actualite.dart';
import 'package:pubfix/Screen_citoyen/dashboard/dashboard.dart';
import 'package:pubfix/Screen_citoyen/profile/account_screen.dart';
import 'package:pubfix/Screen_citoyen/rapport/demande.dart';
import 'package:pubfix/Screen_citoyen/rapport/rapport.dart';

class Home extends StatefulWidget {
  final int initialTabIndex;

  const Home({super.key, this.initialTabIndex = 0});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    return Scaffold(
      body: _pages[_currentTabIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showActionSheet(context);
          /* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DemandeReclamation(),
            ),
          );*/
        },
        backgroundColor: const Color.fromARGB(255, 14, 189, 148),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 65,
        color: const Color.fromARGB(255, 14, 189, 148),
        //  color: const Color.fromARGB(255, 39, 222, 169),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBottomNavigationBarItem(Icons.home, "Acceuil", 0),
              _buildBottomNavigationBarItem(
                  Icons.timer_outlined, "Demandes", 1),
              const Spacer(),
              _buildBottomNavigationBarItem(
                  Icons.app_registration_sharp, "Actualités", 2),
              _buildBottomNavigationBarItem(Icons.settings, "Paramètres", 3),
            ],
          ),
        ),
      ),
    );
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
