import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pubfix/Screen/home_dashboard_Aut.dart';
import 'package:pubfix/global/global_instances.dart';

class Add_Even extends StatefulWidget {
  const Add_Even({super.key});

  @override
  State<Add_Even> createState() => _Add_EvenState();
}

class _Add_EvenState extends State<Add_Even> {
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

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy')
        .format(_selectedDate); // Formater la date pour l'affichage
    Future.delayed(const Duration(seconds: 1), () {
      serviceController.animateTo(10,
          duration: const Duration(seconds: 1), curve: Curves.easeInOut);
    });
  }

  final titreController =
      TextEditingController(); // Nouvelle variable pour le titre
  final descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // Date actuelle par défaut
  final TextEditingController _dateController = TextEditingController();
  final adresseController = TextEditingController();
  String? cible;
  final photoController = TextEditingController();
  File? _imageFile;
  String? selectedEventTitle;
  final _picker = ImagePicker();
  final List<String> eventTitles = [
    'Journée de Nettoyage',
    'Plantation des Arbres',
    'Collecte de Nourriture',
    'Collecte de Fonds',
    'Collecte de Médicaments',
    'Collecte de Sang',
    'Marche Solidaire pour la Santé',
  ];
  buildComplete() {}

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy')
            .format(_selectedDate); // Mettre à jour le champ de texte
      });
    }
  }

  int current = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nouveau Evénement Bénévole",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 14, 189, 148),
      ),
      body: isCompleted
          ? buildComplete()
          : Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                      primary: Color.fromARGB(255, 14, 189, 148))),
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
                                      EvenAddVM.validateEvenementForm(
                                          _imageFile,
                                          titreController.text.trim(),
                                          descriptionController.text.trim(),
                                          _adresseController.text.trim(),
                                          _selectedDate);
                                      commonVM.showSnackBar(
                                          "Evénement ajouté avec succée",
                                          context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Home_Aut(),
                                          ));
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
                      "Titre de l'événement bénévole",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        labelText: "Titre",
                        hintText: "Sélectionnez un titre pour l'événement",
                        prefixIcon: Icon(Icons.title),
                      ),
                      value: selectedEventTitle,
                      items: eventTitles.map((title) {
                        return DropdownMenuItem(
                          value: title,
                          child: Text(title),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedEventTitle = value;
                          titreController.text = value!;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      keyboardType: TextInputType.multiline,
                      minLines: 4,
                      maxLines: 80,
                      maxLength: 400,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          fillColor: Colors.blue,
                          prefixIcon: Icon(Icons.note_add),
                          labelText: "Description",
                          hintText: "Décrivez l'événement en quelques mots"),
                    ),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Date de l'événement",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller:
                      _dateController, // Utiliser le controller pour la date
                  readOnly: true, // Empêcher la saisie manuelle
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    hintText: 'Sélectionner une date',
                  ),
                  onTap: () => _selectDate(context), // Ouvrir le calendrier
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 5),
                SizedBox(
                  height: 220.0,
                  child: Center(
                    child: (_imageFile != null)
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
                    color: const Color.fromARGB(255, 14, 189, 148)),
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
                          hintText: 'Entrez le lieu de événement',
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
