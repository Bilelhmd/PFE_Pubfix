import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pubfix/Screen/welcome_screen.dart';
import 'package:pubfix/Screen_Aut/Notification/Notification.dart';
import 'package:pubfix/Screen_Aut/Settings/edit_screen.dart';
import 'package:pubfix/Screen_Aut/Settings/forward_button.dart';
import 'package:pubfix/Screen_Aut/Settings/setting_item.dart';
import 'package:pubfix/Screen_Aut/Settings/setting_switch.dart';
import 'package:pubfix/global/global_instances.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isDarkMode = false;
  String? _autorite;
  String? _userPhotoUrl;
  bool _isLoading = true;
  String? _nom;
  String? _email;
  String? userId;
  User? currentUser = FirebaseAuth.instance.currentUser;
  final ValueNotifier<bool> _hasNewNotification = ValueNotifier<bool>(false);

  Future<void> _loadAutoriteDetails() async {
    try {
      final details =
          await authautoriteVMODEL.getAutoriteDetailsFromFirestore();
      setState(() {
        _userPhotoUrl = details['Image'];
        _nom = details['Nom'];
        _email = details['Email'];
        userId = currentUser?.uid;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des détails de l\'utilisateur: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchData() async {
    try {
      final autorites =
          await authautoriteVMODEL.getAutoritePhotoFromFirestore();
      setState(() {
        _autorite = autorites;
      });
    } catch (error) {
      print(error); // Handle errors appropriately
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAutoriteDetails();
    _listenToNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 14, 189, 148),
        title: const Text(
          'Paramètres',
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
                          builder: (context) =>
                              NotificationsPage(userId: currentUser?.uid ?? ''),
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
      body: _isLoading
          ? const CircularProgressIndicator()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Compte",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_userPhotoUrl != null)
                                            Image.network(_userPhotoUrl!)
                                          else
                                            Image.asset('assets/logo/logo.png'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: SizedBox(
                              height: 70,
                              width: 70,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _userPhotoUrl != null
                                    ? NetworkImage(_userPhotoUrl!)
                                    : const AssetImage('assets/logo/logo.png')
                                        as ImageProvider,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nom ?? '',
                                //  "Uranus Code",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _email ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                          const Spacer(),
                          ForwardButton(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditAccountScreen(),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Paramètres",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SettingItem(
                      title: "Notifications",
                      icon: Ionicons.notifications,
                      bgColor: Colors.blue.shade100,
                      iconColor: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NotificationsPage(userId: userId!),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SettingSwitch(
                      title: "Mode nuit",
                      icon: Ionicons.earth,
                      bgColor: Colors.purple.shade100,
                      iconColor: Colors.purple,
                      value: isDarkMode,
                      onTap: (value) {
                        setState(() {
                          isDarkMode = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    SettingItem(
                      title: "A propos PubFix",
                      icon: Ionicons.nuclear,
                      bgColor: Colors.red.shade100,
                      iconColor: Colors.red,
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    SettingItem(
                      title: "Deconnexion",
                      icon: Ionicons.log_out,
                      bgColor: Colors.orange.shade100,
                      iconColor: Colors.orange,
                      // value: "English",
                      onTap: () {
                        authVM.logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
      // }
      // }),
    );
  }
}
