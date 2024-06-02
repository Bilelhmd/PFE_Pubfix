import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pubfix/Screen/home_dashboard.dart';
import 'package:pubfix/global/global_instances.dart';
import 'package:pubfix/global/global_var.dart';

class DemandeReclamation extends StatefulWidget {
  const DemandeReclamation({super.key});

  @override
  State<DemandeReclamation> createState() => _DemandeReclamationState();
}

class _DemandeReclamationState extends State<DemandeReclamation> {
  final TextEditingController _adresseController = TextEditingController();

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _mapController?.animateCamera(CameraUpdate.newLatLng(
      LatLng(position.latitude, position.longitude),
    ));

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        _adresseController.text =
            '${place.street}, ${place.locality}, ${place.country}, ${place.isoCountryCode}';
      });
    }
  }

  void _onTap(LatLng position) async {
    setState(() {
      _markers.clear();

      final marker = Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: const InfoWindow(
          title: 'Marqueur personnalisé',
          snippet: 'Un nouveau marqueur ajouté',
        ),
      );
      _markers.add(marker);
    });

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      _adresseController.text =
          '${place.street}, ${place.locality}, ${place.country}, ${place.isoCountryCode}';
    }
  }

  bool isCompleted = false;
  final ScrollController serviceController = ScrollController();
  String _selectedValue = "";

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      serviceController.animateTo(10,
          duration: const Duration(seconds: 1), curve: Curves.easeInOut);
    });
  }

  final descriptionController = TextEditingController();
  final adresseController = TextEditingController();
  String? cible;
  final photoController = TextEditingController();
  String? dropdownvalue = 'STEG';

  List<String> menuItems = <String>[
    "STEG",
    "SONEDE",
    "Municipalité",
    "Direction de l'équipement",
  ];
  File? _imageFile;
  final List<File> _imageFiles = [];

  final _picker = ImagePicker();

  buildComplete() {}
/*SELECTION DES IMAGES MULTIPLE 
  Future<void> _pickImagesFromGallery() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }
*/

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

//MULTIPLE SELCTION OF IMAGES

//END MULTIPLE SELCTION OF IMAGES

  int current = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Creation de rapport",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 14, 189, 148),
        ),
        body: Theme(
          data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
            primary: Color.fromARGB(255, 14, 189, 148),
          )),
          child: SafeArea(
            child: Stepper(
                type: StepperType.horizontal,
                steps: getSteps(),
                currentStep: current,
                onStepContinue: () {
                  final isLastStep = current == getSteps().length - 1;
                  if (isLastStep) {
                    setState(() {
                      isCompleted = true;
                    });
                  } else {
                    setState(() {
                      current += 1;
                    });
                  }
                },
                onStepCancel: current == 0
                    ? null
                    : () {
                        setState(() {
                          current -= 1;
                        });
                      },
                onStepTapped: (step) => setState(() {
                      current = step;
                    }),
                controlsBuilder: (context, ControlsDetails details) {
                  final isLastStep = current == getSteps().length - 1;
                  return Row(
                    children: [
                      if (current != 0)
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue),
                            onPressed: details.onStepCancel,
                            child: const Text(
                              'Précedent',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 14, 189, 148),
                          ),
                          onPressed: isLastStep
                              ? () {
                                  ReportVM.soumettre(
                                      _imageFile,
                                      sharefPrefrences!
                                          .getString("name")
                                          .toString(),
                                      sharefPrefrences!
                                          .getString("email")
                                          .toString(),
                                      descriptionController.text.trim(),
                                      _selectedValue,
                                      _adresseController.text.trim(),
                                      cible.toString(),
                                      sharefPrefrences!
                                          .getString("uid")
                                          .toString(),
                                      DateTime.now(),
                                      sharefPrefrences!
                                          .getString('phone')
                                          .toString());

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const Home(initialTabIndex: 1),
                                    ),
                                  );
                                }
                              : details.onStepContinue,
                          child: Text(
                            isLastStep ? 'Soumettre' : 'Suivant',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }

  List<Step> getSteps() => [
        Step(
          state: current > 0 ? StepState.complete : StepState.indexed,
          isActive: current >= 0,
          title: const Text(''),
          content: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Direction ciblé",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    Container(
                      child: DropdownButtonFormField(
                          hint: const Text("Selectionnez la direction ciblé"),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          items: menuItems.map((String menuItems) {
                            return DropdownMenuItem(
                              value: menuItems,
                              child: Text(menuItems),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownvalue = newValue;
                              cible = newValue;
                            });
                          }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      keyboardType: TextInputType.multiline,
                      minLines: 2,
                      maxLines: 6,
                      maxLength: 100,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          fillColor: Colors.blue,
                          prefixIcon: Icon(Icons.note_add),
                          labelText: "Description",
                          hintText: "Description"),
                    ),
                    const SizedBox(
                      height: 5,
                    ),

                    //CETEGORIES
                    ButtonBar(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.add_a_photo),
                          onPressed: () async => _pickImageFromCamera(),
                          tooltip: 'Shoot picture',
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_photo_alternate),
                          onPressed: () async => _pickImageFromGallery(),
                          tooltip: 'Pick from gallery',
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 220.0,
                      //  width: MediaQuery.of(context).size.width * 0.8,

                      child: Center(
                        child:
                            /* _imageFiles.isNotEmpty
                            ? Wrap(
                                spacing: 10,
                                children: _imageFiles.map((file) {
                                  return Image.file(file,
                                      width: 100, height: 100);
                                }).toList(),
                              )
                            : const Text('No images selected.'),*/
                            (_imageFile != null)
                                ? Image.file(
                                    _imageFile!,
                                    fit: BoxFit.contain,
                                  )
                                : const Text('Aucune image sélectionnée'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Step(
          state: current > 1 ? StepState.complete : StepState.indexed,
          isActive: current >= 1,
          title: const Text(''),
          content: Container(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              //  controller: serviceController,
              padding: const EdgeInsets.all(8),
              children: [
                const Text(
                  "Selectionner service",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "Déchets",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: const Text('Déchets sortis illégalement'),
                  leading: const Icon(
                      IconData(0xf1170, fontFamily: 'MaterialIcons')),
                  onTap: () {
                    setState(() {
                      _selectedValue = 'Déchets sortis illégalement';
                    });
                  },
                ),
                ListTile(
                  title: const Text('Déchets éparpillés'),
                  leading: const Icon(
                      IconData(0xf1170, fontFamily: 'MaterialIcons')),
                  onTap: () {
                    setState(() {
                      _selectedValue = 'Déchets éparpillés';
                    });
                  },
                ),
                ListTile(
                  title: const Text('Poubelle débordante de déchets'),
                  leading: const Icon(
                      IconData(0xf1170, fontFamily: 'MaterialIcons')),
                  onTap: () {
                    setState(() {
                      _selectedValue = 'Poubelle débordante de déchets';
                    });
                  },
                ),
                const Text(
                  "Dommage aux rues et aux parcs",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: const Text('Nid de poule'),
                  leading: const Icon(
                      IconData(0xf1170, fontFamily: 'MaterialIcons')),
                  onTap: () {
                    setState(() {
                      _selectedValue = 'Nid de poule';
                    });
                  },
                ),
                ListTile(
                  title: const Text('Trotoir cassé'),
                  leading: const Icon(
                      IconData(0xf1170, fontFamily: 'MaterialIcons')),
                  onTap: () {
                    setState(() {
                      _selectedValue = 'Trotoir cassé';
                    });
                  },
                ),
                ListTile(
                  title: const Text('Equipement de parc endommagé'),
                  leading: const Icon(
                      IconData(0xf1170, fontFamily: 'MaterialIcons')),
                  onTap: () {
                    setState(() {
                      _selectedValue = 'Equipement de parc endommagé';
                    });
                  },
                ),
                const Text(
                  "Lumières",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: const Text('Feu de circulation'),
                  leading: const Icon(
                      IconData(0xf1170, fontFamily: 'MaterialIcons')),
                  onTap: () {
                    setState(() {
                      _selectedValue = 'Feu de circulation';
                    });
                  },
                ),
                ListTile(
                  title: const Text('Feu de parc'),
                  leading: const Icon(
                      IconData(0xf1170, fontFamily: 'MaterialIcons')),
                  onTap: () {
                    setState(() {
                      _selectedValue = 'Feu de parc';
                    });
                  },
                ),
                ListTile(
                  title: const Text('Lampadaires'),
                  leading: const Icon(
                      IconData(0xf1170, fontFamily: 'MaterialIcons')),
                  onTap: () {
                    setState(() {
                      _selectedValue = 'Lampadaires';
                    });
                  },
                ),
                const Text(
                  "Vehicule/Stationnement",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: const Text('Stationnement illégal'),
                  leading: const Icon(
                      IconData(0xf1170, fontFamily: 'MaterialIcons')),
                  onTap: () {
                    setState(() {
                      _selectedValue = 'Stationnement illégal';
                    });
                  },
                ),
                ListTile(
                  title: const Text('Véhicule abandonné'),
                  leading: const Icon(
                      IconData(0xf1170, fontFamily: 'MaterialIcons')),
                  onTap: () {
                    setState(() {
                      _selectedValue = 'Véhicule abandonné';
                    });
                  },
                ),
                ListTile(
                  title: const Text('Vélo/Moto abandonné'),
                  leading: const Icon(
                      IconData(0xf1170, fontFamily: 'MaterialIcons')),
                  onTap: () {
                    setState(() {
                      _selectedValue = 'Vélo/Moto abandonné';
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        Step(
          state: current > 2 ? StepState.complete : StepState.indexed,
          isActive: current >= 2,
          title: const Text(''),
          content: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  color: const Color.fromARGB(255, 14, 189, 148),
                ),
                child: GoogleMap(
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  onMapCreated: _onMapCreated,
                  onTap: _onTap,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(32.929674, 10.451767),
                    zoom: 14.0,
                  ),
                  markers: _markers,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                          onPressed: _getUserLocation,
                          icon: const Icon(Icons.gps_fixed_sharp)),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      flex: 8,
                      child: TextField(
                        controller: _adresseController,
                        decoration: const InputDecoration(
                          hintText: 'Entrez votre adresse ici',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ];
}
