import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pubfix/Model/Demande/demande_model_list.dart';
import 'package:pubfix/ViewModel/demande/rapport_view_model.dart';
import 'package:pubfix/global/global_instances.dart';
import 'package:pubfix/global/global_var.dart';

class DetailRapport extends StatefulWidget {
  const DetailRapport({super.key});

  @override
  _DetailRapportState createState() => _DetailRapportState();
}

class _DetailRapportState extends State<DetailRapport> {
  bool isFavorite = false;

  AnimationController? animationController;
  Animation<double>? animation;
  final double infoHeight = 364.0;

  final TextEditingController _adresseController = TextEditingController();

  //POUR L'AFFICHAGE DE LA CARTE

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

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

  List<DemandeModelList> itemsData = [];
  final FirestoreService _firestoreService = FirestoreService();

  void getDemandesData() async {
    List<DemandeModelList> responseList = await _firestoreService.getDemandes();

    setState(() {
      itemsData = responseList;
    });
  }

  @override
  void initState() {
    super.initState();
    getDemandesData();
    controller.addListener(() {
      double value = controller.offset / 119;

      setState(() {
        topContainer = value;
        closeTopContainer = controller.offset > 50;
      });
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
        backgroundColor: Colors.white,
        body: itemsData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: SizedBox(
                  height: size.height * 0.7,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                          child: ListView.builder(
                              controller: controller,
                              itemCount: itemsData.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final demande = itemsData[index];
                                Timestamp timestamp =
                                    Timestamp.fromDate(demande.date);

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
                                                child: demande.image.isNotEmpty
                                                    ? Image.network(
                                                        demande.image,
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
                                                  print(
                                                      "riadh :${demande.numberOfApprovals}");

                                                  _adresseController.text =
                                                      demande.adresse;
                                                  searchAndMarkAddress(
                                                      demande.adresse,
                                                      demande.service,
                                                      demande.description);
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
                                                                            demande.adresse,
                                                                            demande.service,
                                                                            demande.description);
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
                                                                              demande.service,
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
                                                                                    demande.cible,
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
                                                                                    demande.demandeur,
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
                                                                                    demande.date != null ? authVM.formatDate(authVM.timestampToDateTime(timestamp)) : "",
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
                                                                                  demande.description,
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
                                                                                      builder: (context) => ImageZoomPage(imageUrl: demande.image),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                child: Image.network(
                                                                                  demande.image,
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
                                                                      InkWell(
                                                                    onTap: () {
                                                                      final user = FirebaseAuth
                                                                          .instance
                                                                          .currentUser;
                                                                      if (user ==
                                                                          null) {
                                                                        // Handle unauthenticated user
                                                                        return;
                                                                      }

                                                                      try {
                                                                        //verification apprové
                                                                        if (demande
                                                                            .isUrgent) {
                                                                          // Show message that approval has already been done
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(const SnackBar(content: Text('Vous avez déjà approuvé cette demande.')));
                                                                          return;
                                                                        }
                                                                        //Verification submitted

                                                                        // Show confirmation dialog
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            return AlertDialog(
                                                                              title: const Text('Confirmation'),
                                                                              content: const Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Êtes-vous sûr de vouloir approuver cette demande ?',
                                                                                    style: TextStyle(fontSize: 16),
                                                                                  ),
                                                                                  SizedBox(height: 10),
                                                                                  Text(
                                                                                    'L\'approbation est une action importante et critique. Une fois approuvée, cette demande ne peut pas être annulée.',
                                                                                    style: TextStyle(color: Colors.red),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              actions: <Widget>[
                                                                                TextButton(
                                                                                  onPressed: () async {
                                                                                    print("riadh :${demande.numberOfApprovals}");

                                                                                    // Toggle the isUrgent state
                                                                                    setState(() {
                                                                                      demande.isUrgent = !demande.isUrgent;
                                                                                    });

                                                                                    // Close the dialog
                                                                                    Navigator.of(context).pop();

                                                                                    try {
                                                                                      // Update Firestore and show success message
                                                                                      if (demande.isUrgent) {
                                                                                        await _firestoreService.addApprobationDocument(demande.id, demande.demandeur);
                                                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                                                          content: Text('Approbation faite avec succès.'),
                                                                                        ));
                                                                                      }

                                                                                      // Verification submitted
                                                                                      if (demande.numberOfApprovals >= 1) {
                                                                                        await ReclamVM.validatereclamationForm(
                                                                                          demande.id,
                                                                                          demande.image,
                                                                                          sharefPrefrences!.getString("name").toString(),
                                                                                          demande.adresse,
                                                                                          demande.service,
                                                                                          demande.cible,
                                                                                          demande.description,
                                                                                          demande.uid_demandeur,
                                                                                          demande.phone,
                                                                                        );
                                                                                      }
                                                                                    } catch (e) {
                                                                                      print("Error: $e");
                                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                                        content: Text('Erreur : $e'),
                                                                                      ));
                                                                                    }
                                                                                  },
                                                                                  child: const Text('Confirmer'),
                                                                                ),
                                                                                TextButton(
                                                                                  onPressed: () {
                                                                                    // Close the dialog
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                  child: const Text('Annuler'),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          },
                                                                        );
                                                                      } catch (error) {
                                                                        // Handle error
                                                                        print(
                                                                            'Error: $error');
                                                                      }
                                                                    },
                                                                    child: demande
                                                                            .isUrgent
                                                                        ? const Icon(
                                                                            Icons
                                                                                .favorite,
                                                                            color: Colors
                                                                                .red)
                                                                        : const Icon(
                                                                            Icons
                                                                                .favorite,
                                                                            color:
                                                                                Colors.white),
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
                                                            demande.service,
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
                                                          demande.description,
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
                                                    color: demande.status ==
                                                            'En attente'
                                                        ? Colors.green
                                                        : demande.status ==
                                                                'Clôturée'
                                                            ? Colors.blue
                                                            : Colors.red,
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
