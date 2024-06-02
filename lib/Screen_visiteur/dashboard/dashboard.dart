import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pubfix/Model/Demande/demande_model_list.dart';
import 'package:pubfix/Screen/home_dashboard.dart';
import 'package:pubfix/Screen/welcome_screen.dart';
import 'package:pubfix/Screen_citoyen/rapport/liste_totale_horizontal.dart';
import 'package:pubfix/Screen_visiteur/liste_actualite_horizontal.dart';
import 'package:pubfix/ViewModel/demande/rapport_view_model.dart';
import 'package:pubfix/global/global_instances.dart';

class Dashboard_Visiteur extends StatefulWidget {
  const Dashboard_Visiteur({super.key});

  @override
  State<Dashboard_Visiteur> createState() => _Dashboard_VisiteurState();
}

class _Dashboard_VisiteurState extends State<Dashboard_Visiteur> {
  bool isSelected = false;
  AnimationController? animationController;
  Animation<double>? animation;
  final double infoHeight = 364.0;
  ////FONCTION POUR AFFICHER LES CARTES
  ///  //FIN AFFICHAGE DE LA CARTE
  bool isFavorite = false;

  //final DateFormat formatter = DateFormat('d MMMM yyyy', 'fr'); // French locale

  final FirestoreService _firestoreService = FirestoreService();
  List<DemandeModelList> _demandes = [];
  // final Set<Marker> _markers = {};
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

  final TextEditingController _adresseController = TextEditingController();

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _userPosition; // Position de l'utilisateur

  @override
  void initState() {
    super.initState();
    _getMarkersFromFirestore();
    _loadUserLocation();
    authVM.buildProfileAvatar();
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
    // Remplacez 'your_collection' par le nom de votre collection Firestore
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
            backgroundColor: const Color.fromARGB(255, 14, 189, 148),
            title: const Text(
              'PubFix.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Se connecter !",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
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
                        height: 180,
                        color: Colors.transparent,
                        child: const DetailRapportHorizontal())),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black, // Couleur de la bordure
                          width: 1.0, // Épaisseur de la bordure
                        ),
                        borderRadius:
                            BorderRadius.circular(15.0), // Bordure arrondie
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            8.0), // Pour que la bordure s'applique à l'intérieur également
                        child: GestureDetector(
                          onTap:
                              () {}, // Capture les autres gestes si nécessaire
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: const CameraPosition(
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
                        child: const ListeActualiteHorizontalVisiteur())),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          )),
    );
  }
}
