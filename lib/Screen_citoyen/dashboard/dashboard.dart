import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pubfix/Model/Demande/demande_model_list.dart';
import 'package:pubfix/Screen/home_dashboard.dart';
import 'package:pubfix/Screen_citoyen/Actualite/liste_actualite_horizontal.dart';
import 'package:pubfix/Screen_citoyen/Evenement/Liste_even.dart';
import 'package:pubfix/Screen_citoyen/Evenement/liste_evenement_horizontal.dart';
import 'package:pubfix/Screen_citoyen/Notification/Notification.dart';
import 'package:pubfix/Screen_citoyen/rapport/liste_totale_horizontal.dart';
import 'package:pubfix/ViewModel/demande/rapport_view_model.dart';
import 'package:pubfix/global/global_instances.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isSelected = false;
  AnimationController? animationController;
  Animation<double>? animation;
  final double infoHeight = 364.0;
  bool isFavorite = false;
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final ValueNotifier<bool> _hasNewNotification = ValueNotifier<bool>(false);
  List<DemandeModelList> _demandes = [];
  Future<Map<String, dynamic>>? _fetchDataFuture;
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

  Future<void> _fetchData() async {
    try {
      final demandes = await _firestoreService.getDemandes();
      setState(() {
        _demandes = demandes;
      });
    } catch (error) {
      print(error); // Handle errors appropriately
    }
  }

  void _listenToNotifications() {
    FirebaseFirestore.instance
        .collection('Users')
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

  final TextEditingController _adresseController = TextEditingController();

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _userPosition; // Position de l'utilisateur

  @override
  void initState() {
    super.initState();
    _getMarkersFromFirestore();
    _loadUserLocation();
    _listenToNotifications();
    authVM.buildProfileAvatar();
    _fetchDataFuture = fetchData();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _loadUserLocation() async {
    LatLng? userLocation = await authVMODEL.getUserAddress();
    setState(() {
      _userPosition = userLocation;
    });
  }

  void _getMarkersFromFirestore() async {
    // Récupérer les données depuis Firestore
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Demandes').get();

    // Parcourir les documents et créer les marqueurs correspondants
    querySnapshot.docs.forEach((DocumentSnapshot document) async {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      String address = data['Adresse'];
      String titre = data['Service'];
      String description = data['Description'];

      // Utiliser Geocoding pour obtenir les coordonnées à partir de l'adresse
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        setState(() {
          //  _markers.clear();
          _markers.add(
            Marker(
              markerId: MarkerId(address),
              position: LatLng(location.latitude, location.longitude),
              infoWindow: InfoWindow(
                title: titre,
                snippet: description,
              ),
            ),
          );
        });
      }
    });
  }

  Future<Map<String, dynamic>> fetchData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Demandes').get();

    int totalReclamations = querySnapshot.docs.length;
    int ReclamationEnAttente =
        querySnapshot.docs.where((doc) => doc['Status'] == 'En attente').length;
    int ReclamationEnCours =
        querySnapshot.docs.where((doc) => doc['Status'] == 'En cours').length;
    int ReclamationClotures =
        querySnapshot.docs.where((doc) => doc['Status'] == 'Clôturée').length;

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
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(255, 14, 189, 148),
            title: const Text(
              'PubFix.',
              style: TextStyle(color: Colors.white),
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
                child: authVM.buildProfileAvatar(),
              ),
              const SizedBox(
                width: 15,
              ),
            ],
          ),
          body: _userPosition == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, top: 8, bottom: 8),
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: _fetchDataFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              final data = snapshot.data!;
                              return Column(
                                children: [
                                  const Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Statistiques",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
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
                                            percent: data[
                                                        'totalReclamations'] ==
                                                    0
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
                                            percent: data[
                                                        'ReclamationEnCours'] ==
                                                    0
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
                                            percent: data[
                                                        'ReclamationClotures'] ==
                                                    0
                                                ? 0
                                                : data['ReclamationClotures'] /
                                                    data['totalReclamations'],
                                            center: data[
                                                        'ReclamationClotures'] ==
                                                    0
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
                              child: const DetailRapportHorizontal())),
                      TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          Colors.black, // Couleur de la bordure
                                      width: 1.0, // Épaisseur de la bordure
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        15.0), // Bordure arrondie
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Pour que la bordure s'applique à l'intérieur également
                                    child: GestureDetector(
                                      onTap:
                                          () {}, // Capture les autres gestes si nécessaire
                                      child: GoogleMap(
                                        onMapCreated: _onMapCreated,
                                        initialCameraPosition:
                                            _userPosition != null
                                                ? CameraPosition(
                                                    target: _userPosition!,
                                                    zoom: 14.0,
                                                  )
                                                : const CameraPosition(
                                                    target: LatLng(32.929674,
                                                        10.451767), // Coordonnées de Tataouine
                                                    zoom: 14.0,
                                                  ),
                                        markers: _markers,
                                        myLocationEnabled: true,
                                        myLocationButtonEnabled: true,
                                        zoomGesturesEnabled:
                                            true, // Activation des gestes de zoom
                                        scrollGesturesEnabled:
                                            true, // Activation des gestes de scroll
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                        child: const Row(
                          children: [
                            Spacer(),
                            Text("Afficher sur carte Map "),
                            Icon(Icons.map_sharp),
                            Spacer(),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
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
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, top: 0, bottom: 0),
                        child: Row(
                          children: [
                            const Text(
                              "Evénements Bénévoles",
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
                                        const ListeEvenement(),
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
                              child: const ListeEvenementHorizontal())),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                )),
    );
  }
}
