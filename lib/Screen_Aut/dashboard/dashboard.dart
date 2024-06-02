import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pubfix/Model/Reclamation/Reclamation_model.dart';
import 'package:pubfix/Screen/home_dashboard.dart';
import 'package:pubfix/Screen_Aut/Notification/Notification.dart';
import 'package:pubfix/Screen_Aut/Reclamation/liste_totale_horizontal.dart';
import 'package:pubfix/Screen_citoyen/Actualite/liste_actualite_horizontal.dart';
import 'package:pubfix/ViewModel/Reclamation/reclamation_view_model.dart';
import 'package:pubfix/global/global_instances.dart';

class DashboardAut extends StatefulWidget {
  const DashboardAut({super.key});

  @override
  State<DashboardAut> createState() => _DashboardAutState();
}

class _DashboardAutState extends State<DashboardAut> {
  bool isFavorite = false;
  List<reclamationModelList> _reclamations = [];
  AnimationController? animationController;
  Animation<double>? animation;
  final double infoHeight = 364.0;
  final TextEditingController _adresseController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirestoreService _firestoreService = FirestoreService();
  final ValueNotifier<bool> _hasNewNotification = ValueNotifier<bool>(false);
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  String selectedstatutForEdit = '';

  String commentaire = '';

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void searchAndMarkAddress(String address, String serv, String desc) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng position = LatLng(location.latitude, location.longitude);
        setState(() {
          _markers.clear();
          final marker = Marker(
            markerId: MarkerId(position.toString()),
            position: position,
            infoWindow: InfoWindow(title: serv, snippet: desc),
          );
          _markers.add(marker);
        });
        await _mapController?.animateCamera(CameraUpdate.newLatLng(position));

        await Future.delayed(const Duration(milliseconds: 500));

        _adresseController.text = address;
        //     print(_adresseController.text);
      } else {
        // print('Adresse introuvable');
      }
    } catch (e) {
      //  print('Erreur lors de la recherche d\'adresse : $e');
    }
  }

  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _listenToNotifications();
    authautoriteVMODEL.buildProfileAvatar();
    controller.addListener(() {
      double value = controller.offset / 119;

      setState(() {
        topContainer = value;
        closeTopContainer = controller.offset > 50;
      });
    });
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
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _hasNewNotification.value = true;
      }
    });
  }

  Future<Map<String, dynamic>> fetchData() async {
    // Remplacez 'your_collection' par le nom de votre collection Firestore
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Reclamation').get();

    int totalReclamations = querySnapshot.docs.length;
    int ReclamationEnAttente =
        querySnapshot.docs.where((doc) => doc['Statut'] == 'En attente').length;
    int ReclamationEnCours =
        querySnapshot.docs.where((doc) => doc['Statut'] == 'En cours').length;
    int ReclamationClotures =
        querySnapshot.docs.where((doc) => doc['Statut'] == 'Clôturée').length;

    return {
      'totalReclamations': totalReclamations,
      'ReclamationEnAttente': ReclamationEnAttente,
      'ReclamationEnCours': ReclamationEnCours,
      'ReclamationClotures': ReclamationClotures,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: null, // Ceci enlève le bouton de retour
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(255, 14, 189, 148),
            elevation: 0.0,
            title: Text(
              'PubFix.',
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
                              builder: (context) => NotificationsPage(
                                  userId: currentUser?.uid ?? ''),
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
              SizedBox(
                height: 40,
                width: 40,
                child: authautoriteVMODEL.buildProfileAvatar(),
              ),
              const SizedBox(
                width: 15,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 8, bottom: 8),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: fetchData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        final data = snapshot.data!;
                        return Column(
                          children: [
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Statistiques",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    CircularPercentIndicator(
                                      radius: 50.0,
                                      lineWidth: 5.0,
                                      percent: data['totalReclamations'] == 0
                                          ? 0 / data['totalReclamations']
                                          : data['ReclamationEnAttente'] /
                                              data['totalReclamations'],
                                      center: Text(
                                          "${data['ReclamationEnAttente']}/${data['totalReclamations']}"),
                                      progressColor: Colors.green,
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.6),
                                      circularStrokeCap:
                                          CircularStrokeCap.round,
                                      animation: true,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    const Text(
                                      "Réclamations",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    const Text(
                                      "en attente",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    CircularPercentIndicator(
                                      radius: 50.0,
                                      lineWidth: 5.0,
                                      percent: data['ReclamationEnCours'] == 0
                                          ? 0 / data['totalReclamations']
                                          : data['ReclamationEnCours'] /
                                              data['totalReclamations'],
                                      center: Text(
                                          "${data['ReclamationEnCours']}/${data['totalReclamations']}"),
                                      progressColor: Colors.blue,
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.6),
                                      circularStrokeCap:
                                          CircularStrokeCap.round,
                                      animation: true,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    const Text(
                                      "Réclamations",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    const Text(
                                      "en cours",
                                      style: TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    CircularPercentIndicator(
                                      radius: 50.0,
                                      lineWidth: 5.0,
                                      percent: data['ReclamationClotures'] == 0
                                          ? 0
                                          : data['ReclamationClotures'] /
                                              data['totalReclamations'],
                                      center: data['ReclamationClotures'] == 0
                                          ? Text(
                                              "0/${data['totalReclamations']}")
                                          : Text(
                                              "${data['ReclamationClotures']}/${data['totalReclamations']}"),
                                      progressColor: Colors.red,
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.6),
                                      circularStrokeCap:
                                          CircularStrokeCap.round,
                                      animation: true,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    const Text(
                                      "Réclamations",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    const Text(
                                      "Clôturées",
                                      style: TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 0, bottom: 0),
                  child: Row(
                    children: [
                      const Text(
                        "Réclamations",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const Home(initialTabIndex: 1),
                            ),
                          );
                        },
                        child: const Text(
                          "Voir tout",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 0, bottom: 0),
                    child: Container(
                        height: 160,
                        color: Colors.transparent,
                        child: const DetailRapportHorizontalAut())),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 0, bottom: 0),
                  child: Row(
                    children: [
                      const Text(
                        "Actualités",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const Home(initialTabIndex: 2),
                            ),
                          );
                        },
                        child: const Text(
                          "Voir tout",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 0, bottom: 0),
                    child: Container(
                        height: 150,
                        color: Colors.transparent,
                        child: const ListeActualiteHorizontal())),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          )),
    );
  }
}
