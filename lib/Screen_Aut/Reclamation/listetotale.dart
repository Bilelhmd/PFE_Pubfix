import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pubfix/Model/Reclamation/Reclamation_model.dart';
import 'package:pubfix/Screen/home_dashboard_Aut.dart';
import 'package:pubfix/Screen_Aut/Notification/Notification.dart';
import 'package:pubfix/ViewModel/Reclamation/reclamation_view_model.dart';
import 'package:pubfix/global/global_instances.dart';

class ListeTotale extends StatefulWidget {
  const ListeTotale({super.key});

  @override
  _ListeTotaleState createState() => _ListeTotaleState();
}

class _ListeTotaleState extends State<ListeTotale> {
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

  @override
  Widget build(BuildContext context) {
    final double tempHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.width / 1.2) +
        24.0;
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
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
        body: _reclamations.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: SizedBox(
                  height: size.height * 0.7,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                          child: ListView.builder(
                              //      scrollDirection: Axis.vertical,
                              controller: controller,
                              itemCount: _reclamations.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final reclamation = _reclamations[index];
                                Timestamp timestamp =
                                    Timestamp.fromDate(reclamation.date);

                                double scale = 1.0;
                                if (topContainer > 0.5) {
                                  scale = index + 0.5 - topContainer;
                                  if (scale < 0) {
                                    scale = 0;
                                  } else if (scale > 1) {
                                    scale = 1;
                                  }
                                }
                                return Opacity(
                                  opacity: scale,
                                  child: Transform(
                                    transform: Matrix4.identity()
                                      ..scale(scale, scale),
                                    alignment: Alignment.bottomCenter,
                                    child: Align(
                                      heightFactor: 0.7,
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.85,
                                        height: 130,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 5),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(20.0)),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withAlpha(100),
                                              blurRadius: 10.0,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // Image Container
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15,
                                                  right: 0,
                                                  top: 15,
                                                  bottom: 15),
                                              child: Container(
                                                width: 70,
                                                height: double.infinity + 50,
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                child: reclamation
                                                        .image.isNotEmpty
                                                    ? Image.network(
                                                        reclamation.image,
                                                        fit: BoxFit.contain,
                                                      )
                                                    : const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 20),
                                              ),
                                            ),
                                            // Rest of the content
                                            Expanded(
                                              child: ListTile(
                                                onTap: () {
                                                  _adresseController.text =
                                                      reclamation.localisation;
                                                  searchAndMarkAddress(
                                                      reclamation.localisation,
                                                      reclamation.titre,
                                                      reclamation.description);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute<Widget>(
                                                        builder: (BuildContext
                                                            context) {
                                                      return Scaffold(
                                                        body: Stack(
                                                          children: [
                                                            Column(
                                                              children: [
                                                                AspectRatio(
                                                                  aspectRatio:
                                                                      1.2,
                                                                  child:
                                                                      Container(
                                                                    //height:MediaQuery.of(context).size.height *0.5,
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            width:
                                                                                1),
                                                                        color: Colors
                                                                            .transparent),
                                                                    child:
                                                                        GoogleMap(
                                                                      gestureRecognizers: <Factory<
                                                                          OneSequenceGestureRecognizer>>{
                                                                        Factory<
                                                                            OneSequenceGestureRecognizer>(
                                                                          () =>
                                                                              EagerGestureRecognizer(),
                                                                        ),
                                                                      },
                                                                      markers:
                                                                          _markers,
                                                                      onMapCreated:
                                                                          (controller) {
                                                                        _mapController =
                                                                            controller;
                                                                        //    setState(() {
                                                                        searchAndMarkAddress(
                                                                            reclamation.localisation,
                                                                            reclamation.titre,
                                                                            reclamation.description);
                                                                        //    });
                                                                      },
                                                                      //       onTap: _onTap,
                                                                      initialCameraPosition:
                                                                          const CameraPosition(
                                                                        target: LatLng(
                                                                            32.929674,
                                                                            10.451767),
                                                                        zoom:
                                                                            14.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Positioned(
                                                              top: (MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      1.2) -
                                                                  24.0,
                                                              bottom: 0,
                                                              left: 0,
                                                              right: 0,
                                                              child: Container(
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              32.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              32.0)),
                                                                  boxShadow: <BoxShadow>[
                                                                    BoxShadow(
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            15,
                                                                            16,
                                                                            16),
                                                                        offset: Offset(
                                                                            1.1,
                                                                            1.1),
                                                                        blurRadius:
                                                                            10.0),
                                                                  ],
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              8,
                                                                          right:
                                                                              8),
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Container(
                                                                      constraints: BoxConstraints(
                                                                          minHeight:
                                                                              infoHeight,
                                                                          maxHeight: tempHeight > infoHeight
                                                                              ? tempHeight
                                                                              : infoHeight),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Padding(
                                                                            padding: const EdgeInsets.only(
                                                                                top: 32.0,
                                                                                left: 18,
                                                                                right: 16),
                                                                            child:
                                                                                Text(
                                                                              reclamation.titre,
                                                                              //  textAlign: TextAlign.left,
                                                                              style: GoogleFonts.poppins(
                                                                                fontSize: 22.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: Colors.black,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsets.only(
                                                                                left: 16,
                                                                                right: 16,
                                                                                bottom: 8,
                                                                                top: 16),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: <Widget>[
                                                                                const Flexible(
                                                                                  flex: 3,
                                                                                  child: Text(
                                                                                    "Direction cible : ",
                                                                                    textAlign: TextAlign.left,
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'Roboto',
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: 13,
                                                                                      color: Color.fromARGB(255, 8, 25, 40),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Flexible(
                                                                                  flex: 4,
                                                                                  child: Text(
                                                                                    reclamation.cible,
                                                                                    textAlign: TextAlign.left,
                                                                                    style: const TextStyle(
                                                                                      fontFamily: 'Roboto',
                                                                                      fontSize: 12,
                                                                                      color: Colors.blue,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsets.only(
                                                                                left: 16,
                                                                                right: 16,
                                                                                bottom: 8,
                                                                                top: 16),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: <Widget>[
                                                                                const Expanded(
                                                                                  flex: 1,
                                                                                  child: Text(
                                                                                    "Demandé par",
                                                                                    textAlign: TextAlign.left,
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'Roboto',
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: 14,
                                                                                      letterSpacing: 0.27,
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 1,
                                                                                  child: Text(
                                                                                    reclamation.demandeur,
                                                                                    textAlign: TextAlign.left,
                                                                                    style: const TextStyle(
                                                                                      fontFamily: 'Roboto',
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: 14,
                                                                                      letterSpacing: 0.27,
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 1,
                                                                                  child: Text(
                                                                                    // ignore: unnecessary_null_comparison
                                                                                    reclamation.date != null ? authVM.formatDate(authVM.timestampToDateTime(timestamp)) : "",
                                                                                    style: const TextStyle(
                                                                                      fontFamily: 'Roboto',
                                                                                      fontSize: 12,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                AnimatedOpacity(
                                                                              duration: const Duration(milliseconds: 500),
                                                                              opacity: 0.8,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                                                                                child: Text(
                                                                                  reclamation.description,
                                                                                  textAlign: TextAlign.justify,
                                                                                  style: const TextStyle(
                                                                                    fontFamily: 'Roboto',
                                                                                    fontWeight: FontWeight.w200,
                                                                                    fontSize: 16,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                  maxLines: 3,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                12,
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsets.only(
                                                                                left: 16,
                                                                                right: 16,
                                                                                top: 8,
                                                                                bottom: 8),
                                                                            child:
                                                                                Center(
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => ImageZoomPage(imageUrl: reclamation.image),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                child: Image.network(
                                                                                  reclamation.image,
                                                                                  height: 150,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const Spacer(),
                                                                          SizedBox(
                                                                            height:
                                                                                MediaQuery.of(context).padding.bottom,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              top: (MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      1.2) -
                                                                  24.0 -
                                                                  35,
                                                              right: 35,
                                                              child: Card(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    39,
                                                                    222,
                                                                    169),
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            50.0)),
                                                                elevation: 10.0,
                                                                child: SizedBox(
                                                                  width: 60,
                                                                  height: 60,
                                                                  child:
                                                                      IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      _showDetailsDialog(
                                                                          context,
                                                                          reclamation);
                                                                    },
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .update,
                                                                        color: Colors
                                                                            .yellow),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(
                                                                  top: MediaQuery.of(
                                                                          context)
                                                                      .padding
                                                                      .top),
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: AppBar()
                                                                        .preferredSize
                                                                        .height,
                                                                    height: AppBar()
                                                                        .preferredSize
                                                                        .height,
                                                                    child:
                                                                        Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      child:
                                                                          InkWell(
                                                                        borderRadius: BorderRadius.circular(AppBar()
                                                                            .preferredSize
                                                                            .height),
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .arrow_back_ios,
                                                                          color:
                                                                              Colors.red,
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                                  );
                                                },
                                                title: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            reclamation.titre,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Divider(),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                          reclamation
                                                              .description,
                                                          //     textAlign: TextAlign.start,
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  ],
                                                ),
                                                trailing: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: reclamation.statut ==
                                                            'En attente'
                                                        ? Colors.green
                                                        : reclamation.statut ==
                                                                'Clôturée'
                                                            ? Colors.red
                                                            : Colors.blue,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color
                                                                .fromARGB(255,
                                                                255, 255, 255)
                                                            .withOpacity(0.2),
                                                        spreadRadius: 2,
                                                        blurRadius: 5,
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              })),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _showDetailsDialog(
      BuildContext context, reclamationModelList reclamation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Options de Réclamation'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer la boîte de dialogue
              _showEditDialog(context, reclamation);
            },
            child: const Text('Mettre à jour'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer la boîte de dialogue
              _showDeleteConfirmationDialog(context, reclamation);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, reclamationModelList reclamation) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Mettre à jour le statut de la réclamation'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      title: Text('Statut',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ListTile(
                      title: Text(
                        'En attente',
                        style: TextStyle(
                          fontWeight: selectedstatutForEdit == 'En attente'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize:
                              selectedstatutForEdit == 'En attente' ? 18 : 16,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedstatutForEdit = 'En attente';
                        });
                      },
                      selected: selectedstatutForEdit == 'En attente',
                    ),
                    ListTile(
                      title: Text(
                        'En cours',
                        style: TextStyle(
                          fontWeight: selectedstatutForEdit == 'En cours'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize:
                              selectedstatutForEdit == 'En cours' ? 18 : 16,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedstatutForEdit = 'En cours';
                        });
                      },
                      selected: selectedstatutForEdit == 'En cours',
                    ),
                    ListTile(
                      title: Text(
                        'Clôturée',
                        style: TextStyle(
                          fontWeight: selectedstatutForEdit == 'Clôturée'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize:
                              selectedstatutForEdit == 'Clôturée' ? 18 : 16,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedstatutForEdit = 'Clôturée';
                        });
                      },
                      selected: selectedstatutForEdit == 'Clôturée',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Commentaire',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        commentaire = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showConfirmationDialog(context, reclamation,
                        selectedstatutForEdit, commentaire);
                  },
                  child: const Text('Valider'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, reclamationModelList reclamation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette réclamation ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Supprimer la réclamation
              _firestoreService.deleteReclamation(reclamation.id);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Home_Aut(),
                  ));
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context,
      reclamationModelList reclamation, newStatut, commentaire) {
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
                commentaire,
              );
              Navigator.pop(context); // Ferme le dialogue de confirmation
              Navigator.pop(
                  context); // Ferme le dialogue de mise à jour du statut
              Navigator.pop(
                  context); // Ferme le dialogue de détails de la réclamation
            },
            child: const Text('Confirmer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}

class ImageZoomPage extends StatelessWidget {
  final String imageUrl;

  const ImageZoomPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('Image Zoom'),
          ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
