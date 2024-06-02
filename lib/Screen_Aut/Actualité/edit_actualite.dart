import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pubfix/Model/Actualite/Actualite_model.dart';
import 'package:pubfix/ViewModel/Actualite/ActualiteViewModel.dart';

class EditActualite extends StatefulWidget {
  final Actualite actualite;

  const EditActualite({required this.actualite, super.key});

  @override
  _EditActualiteState createState() => _EditActualiteState();
}

class _EditActualiteState extends State<EditActualite> {
  final _formKey = GlobalKey<FormState>();
  final ActualiteViewModel _actualiteViewModel = ActualiteViewModel();
  late TextEditingController _titreController;
  late TextEditingController _descriptionController;
  late TextEditingController _localisationController;
  late TextEditingController _dateController;
  DateTime _selectedDate = DateTime.now();
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

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.actualite.titre);
    _descriptionController =
        TextEditingController(text: widget.actualite.description);
    _dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(widget.actualite.date));
    _localisationController =
        TextEditingController(text: widget.actualite.localisation);
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
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _localisationController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        DateTime selectedDate =
            DateFormat('dd/MM/yyyy').parse(_dateController.text);
        Timestamp timestamp = Timestamp.fromDate(selectedDate);

        await _actualiteViewModel.updateActualite(
          widget.actualite.id,
          _titreController.text,
          _descriptionController.text,
          timestamp,
          widget.actualite.autorite,
          _localisationController.text,
        );
        Navigator.pop(context, true);
      } catch (e) {
        print('Error parsing date: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de formatage de la date')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null, // Ceci enlève le bouton de retour
        automaticallyImplyLeading: false,
        title: const Text(
          "Modification d'actualite",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 39, 222, 169),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Autorite: ${widget.actualite.autorite}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    onPressed: () {
                      _selectDate(context);
                    },
                    icon: const Icon(Icons.calendar_month),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _localisationController,
                decoration: InputDecoration(
                  labelText: 'Localisation',
                  suffixIcon: IconButton(
                    onPressed: _openMap,
                    icon: const Icon(Icons.gps_fixed_sharp),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 39, 222, 169),
                ),
                child: const Text(
                  'Modifier',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Select Location'),
            backgroundColor: const Color(0xff05B068),
          ),
          body: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  color: Colors.green,
                ),
                child: GoogleMap(
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer()),
                  },
                  onMapCreated: _onMapCreated,
                  onTap: _onTap,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(32.929674, 10.451767),
                    zoom: 10.0,
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
                        icon: const Icon(Icons.gps_fixed_sharp),
                      ),
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
              ElevatedButton(
                onPressed: () {
                  String newLocation = _adresseController.text;
                  setState(() {
                    _localisationController.text = newLocation;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Valider',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
