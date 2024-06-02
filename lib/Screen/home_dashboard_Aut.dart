import 'package:flutter/material.dart';
import 'package:pubfix/Screen_Aut/Actualit%C3%A9/actualite_list.dart';
import 'package:pubfix/Screen_Aut/Actualit%C3%A9/ajoutactualite.dart';
import 'package:pubfix/Screen_Aut/Actualit%C3%A9/liste_actualitenew.dart';
import 'package:pubfix/Screen_Aut/Reclamation/listereclamation.dart';
import 'package:pubfix/Screen_Aut/Reclamation/listetotale.dart';
import 'package:pubfix/Screen_Aut/Settings/account_screen.dart';
import 'package:pubfix/Screen_Aut/dashboard/dashboard.dart';

class Home_Aut extends StatefulWidget {
  const Home_Aut({super.key});

  @override
  State<Home_Aut> createState() => _Home_AutState();
}

class _Home_AutState extends State<Home_Aut> {
  int currentTab = 0;
  final List<Widget> screen = [
    const ListeTotale(),
    const ListeReclamation(),
    const ListeActualite_aut(),
    const AccountScreen(),
  ];

  final PageStorageBucket buckets = PageStorageBucket();
  Widget currentScreen = const DashboardAut();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: buckets, child: currentScreen),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Add_Actualite(),
              ));
        },
        backgroundColor: const Color.fromARGB(255, 39, 222, 169),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 65,
        color: const Color.fromARGB(255, 39, 222, 169),
//        shape: const CircularNotchedRectangle(),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          //  height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MaterialButton(
                onPressed: () {
                  setState(() {
                    currentScreen = const DashboardAut();
                    currentTab = 0;
                  });
                },
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.home,
                        color: currentTab == 0 ? Colors.black : Colors.white,
                      ),
                      Text(
                        "Accueil",
                        style: TextStyle(
                            fontSize: 8,
                            color:
                                currentTab == 0 ? Colors.black : Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  setState(() {
                    currentScreen = const ListeTotale();
                    currentTab = 1;
                  });
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: currentTab == 1 ? Colors.black : Colors.white,
                    ),
                    Text(
                      "Réclamations",
                      style: TextStyle(
                          fontSize: 8,
                          color: currentTab == 1 ? Colors.black : Colors.white),
                    )
                  ],
                ),
              ),
              const Spacer(),
              MaterialButton(
                onPressed: () {
                  setState(() {
                    currentScreen = const ListeActualite_aut();
                    currentTab = 2;
                  });
                },
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.app_registration_sharp,
                        color: currentTab == 2 ? Colors.black : Colors.white,
                      ),
                      Text(
                        "Actualités",
                        style: TextStyle(
                            fontSize: 8,
                            color:
                                currentTab == 2 ? Colors.black : Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  setState(() {
                    currentScreen = const AccountScreen();
                    currentTab = 3;
                  });
                },
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_circle,
                        color: currentTab == 3 ? Colors.black : Colors.white,
                      ),
                      Text(
                        "Profil",
                        style: TextStyle(
                            fontSize: 8,
                            color:
                                currentTab == 3 ? Colors.black : Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
