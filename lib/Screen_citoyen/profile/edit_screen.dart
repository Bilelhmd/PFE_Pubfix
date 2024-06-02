import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pubfix/Model/Authentication/authentication_model.dart';
import 'package:pubfix/Screen/home_dashboard.dart';
import 'package:pubfix/Screen_citoyen/profile/account_screen.dart';
import 'package:pubfix/global/global_instances.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final TextEditingController _imageController = TextEditingController();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  //UPLOAD IMAGES DES PROFILE
  File? _imageFile;
  final _picker = ImagePicker();

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

  UsersModel? _utilisateur;

  Future<void> _fetchData() async {
    try {
      final utilisateurs = await authVMODEL.getUtilisateurs();
      setState(() {
        _utilisateur = utilisateurs;
      });
    } catch (error) {
      print(error); // Handle errors appropriately
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Succès'),
          content:
              const Text('Vos coordonnées ont été mises à jour avec succès.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Home(initialTabIndex: 3),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountScreen(),
              ),
            );
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<UsersModel?>(
          future: authVMODEL.getUtilisateurs(),
          builder: (context, snapshot) {
            UsersModel? user = snapshot.data;
            _nomController.text = user!.nom;
            _emailController.text = user.email;
            _phoneController.text = user.phone;
            _adresseController.text = user.adresse;
            _passwordController.text = user.password;
            _imageController.text = user.photo;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Compte",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 1),
                                    borderRadius: BorderRadius.circular(75)),
                                height: 150,
                                width: 150,
                                child: CircleAvatar(
                                  backgroundImage: (_imageFile != null)
                                      ? FileImage(_imageFile!)
                                      : NetworkImage(_imageController.text)
                                          as ImageProvider<Object>,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  _pickImageFromGallery();
                                },
                                icon: const Icon(Icons.file_upload_outlined),
                                color: const Color.fromARGB(255, 39, 222, 169),
                                iconSize: 50.0,
                              ),
                              /*   TextButton(
                                onPressed: () async {
                                  _pickImageFromGallery();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.lightBlueAccent,
                                ),
                                child: const Text("Importer photo"),
                              ),*/
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nomController,
                      validator: (value) => value!.isEmpty
                          ? "Le nom ne peut pas être vide."
                          : null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        prefixIcon: Icon(Icons.person),
                        labelText: "Nom complet",
                        hintText: "Tapez votre nom complet",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) => value!.isEmpty
                          ? "L'e-mail ne peut pas être vide."
                          : null,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        prefixIcon: Icon(Icons.email_rounded),
                        labelText: "E-mail",
                        hintText: "Tapez votre e-mail",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        prefixIcon: Icon(Icons.phone),
                        labelText: "N° Téléphone",
                        hintText: "Tapez votre N° téléphone",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _adresseController,
                      validator: (value) => value!.isEmpty
                          ? "L'adresse ne peut pas être vide."
                          : null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        prefixIcon: Icon(Icons.location_on),
                        labelText: "Adresse",
                        hintText: "Tapez votre adresse",
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              authVM.updateUserData(
                                _imageFile,
                                _nomController.text.trim(),
                                _phoneController.text.trim(),
                                _passwordController.text.trim(),
                                _adresseController.text.trim(),
                              );
                              _showSuccessDialog();
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.black26;
                                }
                                return const Color.fromARGB(255, 39, 222, 169);
                              }),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            child: const Text(
                              "Mettre à jour les informations",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
