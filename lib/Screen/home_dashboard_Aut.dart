import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pubfix/Screen_Aut/Actualit%C3%A9/actualite_list.dart';
import 'package:pubfix/Screen_Aut/Actualit%C3%A9/ajoutactualite.dart';
import 'package:pubfix/Screen_Aut/Actualit%C3%A9/liste_actualitenew.dart';
import 'package:pubfix/Screen_Aut/Reclamation/listereclamation.dart';
import 'package:pubfix/Screen_Aut/Reclamation/listetotale.dart';
import 'package:pubfix/Screen_Aut/Settings/account_screen.dart';
import 'package:pubfix/Screen_Aut/dashboard/dashboard.dart';

class Home_Aut extends StatefulWidget {
  final int initialTabIndex;

  const Home_Aut({super.key, this.initialTabIndex = 0});

  @override
  State<Home_Aut> createState() => _Home_AutState();
}

class _Home_AutState extends State<Home_Aut> {
  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Selectionner votre choix'),
        message: const Text('Ajouter une actualité'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Add_Actualite(),
                ),
              );
            },
            child: const Text(
              'Ajouter une actualité',
              style: TextStyle(
                color: Color.fromARGB(255, 16, 130, 58),
              ),
            ),
          ),
        ],
      ),
    );
  }

  late int _currentTabIndex;

  final List<Widget> _pages = [
    const DashboardAut(),
    const ListeTotale(),
    const ListeActualite_aut(),
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
      body: SafeArea(
        child: _pages[_currentTabIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showActionSheet(context);
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
        color: const Color.fromARGB(255, 14, 189, 148),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBottomNavigationBarItem(Icons.home, "Accueil", 0),
              _buildBottomNavigationBarItem(
                  Icons.timer_outlined, "Réclamation", 1),
              // const Spacer(),
              const SizedBox(
                width: 10,
              ),
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
    return Expanded(
      child: MaterialButton(
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
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: _currentTabIndex == index
                      ? const Color.fromRGBO(0, 117, 117, 1)
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
