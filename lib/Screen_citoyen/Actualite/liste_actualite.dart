import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pubfix/Model/Actualite/Actualite_model.dart';
import 'package:pubfix/Screen_citoyen/Notification/Notification.dart';
import 'package:pubfix/global/global_instances.dart';

class ListeActualite extends StatefulWidget {
  const ListeActualite({super.key});

  @override
  _ListeActualiteState createState() => _ListeActualiteState();
}

class _ListeActualiteState extends State<ListeActualite> {
  final String imageUrl = "";
  bool isFavorite = false;
  final ValueNotifier<bool> _hasNewNotification = ValueNotifier<bool>(false);
  AnimationController? animationController;
  Animation<double>? animation;
  final double infoHeight = 364.0;
  final User? currentUser = FirebaseAuth.instance.currentUser;
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

  List<Actualite> itemsData = [];

  void getDemandesData() async {
    List<Actualite> responseList = await ActVM.getActualites();

    setState(() {
      itemsData = responseList;
    });
  }

  @override
  void initState() {
    super.initState();
    authVM.buildProfileAvatar();
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromARGB(255, 14, 189, 148),
          title: const Text(
            'Actualités',
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
        body: SizedBox(
          height: size.height,
          child: Column(
            children: <Widget>[
              Expanded(
                  child: itemsData.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
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
                                    height: 150,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20.0)),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withAlpha(100),
                                              blurRadius: 10.0),
                                        ]),
                                    child: Row(
                                      children: [
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
                                                    width: 80,
                                                    // height: 100,
                                                    fit: BoxFit
                                                        .fitHeight, // Adjust image fit as needed
                                                  )
                                                : const Icon(
                                                    Icons.image_not_supported,
                                                    size:
                                                        20), // Display placeholder if no image
                                          ),
                                        ),
                                        Expanded(
                                          child: ListTile(
                                            onTap: () {
                                              _adresseController.text =
                                                  demande.localisation;
                                              searchAndMarkAddress(
                                                  demande.localisation,
                                                  demande.titre,
                                                  demande.description);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute<Widget>(
                                                    builder:
                                                        (BuildContext context) {
                                                  return Scaffold(
                                                    body: Stack(
                                                      children: [
                                                        Column(
                                                          children: [
                                                            AspectRatio(
                                                              aspectRatio: 1.2,
                                                              child: Container(
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
                                                                        demande
                                                                            .localisation,
                                                                        demande
                                                                            .titre,
                                                                        demande
                                                                            .description);
                                                                    //    });
                                                                  },
                                                                  //       onTap: _onTap,
                                                                  initialCameraPosition:
                                                                      const CameraPosition(
                                                                    target: LatLng(
                                                                        32.929674,
                                                                        10.451767),
                                                                    zoom: 12.0,
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
                                                              color:
                                                                  Colors.white,
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          32.0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          32.0)),
                                                              boxShadow: <BoxShadow>[
                                                                BoxShadow(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            15,
                                                                            16,
                                                                            16),
                                                                    offset:
                                                                        Offset(
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
                                                                      left: 8,
                                                                      right: 8),
                                                              child:
                                                                  SingleChildScrollView(
                                                                      child:
                                                                          Container(
                                                                constraints:
                                                                    BoxConstraints(
                                                                  minHeight:
                                                                      infoHeight,
                                                                  maxHeight: tempHeight >
                                                                          infoHeight
                                                                      ? tempHeight
                                                                      : infoHeight,
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              16.0,
                                                                          left:
                                                                              16,
                                                                          right:
                                                                              16),
                                                                      child:
                                                                          Text(
                                                                        demande
                                                                            .titre,
                                                                        style: GoogleFonts
                                                                            .poppins(
                                                                          fontSize:
                                                                              22.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const Divider(),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              16,
                                                                          right:
                                                                              16,
                                                                          bottom:
                                                                              5,
                                                                          top:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          const Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Text(
                                                                              "Publié par :",
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
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Text(
                                                                              demande.autorite,
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
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Text(
                                                                              demande.date != null ? ActVM.formatDate(ActVM.timestampToDateTime(timestamp)) : "",
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
                                                                        duration:
                                                                            const Duration(milliseconds: 500),
                                                                        opacity:
                                                                            0.8,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 16,
                                                                              right: 16,
                                                                              top: 8,
                                                                              bottom: 8),
                                                                          child:
                                                                              Text(
                                                                            demande.description,
                                                                            textAlign:
                                                                                TextAlign.justify,
                                                                            style:
                                                                                const TextStyle(
                                                                              fontFamily: 'Roboto',
                                                                              fontWeight: FontWeight.w200,
                                                                              fontSize: 16,
                                                                              color: Colors.black,
                                                                            ),
                                                                            maxLines:
                                                                                3,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            12),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => ImageZoomPage(imageUrl: demande.image),
                                                                              ),
                                                                            );
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(15.0),
                                                                              boxShadow: const [
                                                                                BoxShadow(
                                                                                  color: Colors.black26,
                                                                                  blurRadius: 10.0,
                                                                                  offset: Offset(0, 5),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(15.0),
                                                                              child: Image.network(
                                                                                demande.image,
                                                                                height: 250,
                                                                                fit: BoxFit.cover,
                                                                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                                                  if (loadingProgress == null) return child;
                                                                                  return Center(
                                                                                    child: CircularProgressIndicator(
                                                                                      value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                                                                  return const Center(child: Text('Image failed to load', style: TextStyle(color: Colors.red)));
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const Spacer(),
                                                                    SizedBox(
                                                                      height: MediaQuery.of(
                                                                              context)
                                                                          .padding
                                                                          .bottom,
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
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
                                                                child: Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      InkWell(
                                                                    borderRadius:
                                                                        BorderRadius.circular(AppBar()
                                                                            .preferredSize
                                                                            .height),
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .arrow_back_ios,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                    onTap: () {
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
                                            title: Expanded(
                                              child: Text(
                                                demande.titre,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                            ),
                                            subtitle: Column(
                                              children: [
                                                const Divider(),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    demande.autorite,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 11,
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      demande.description,
                                                      textAlign: TextAlign.left,
                                                      maxLines: 3,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              ],
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
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
