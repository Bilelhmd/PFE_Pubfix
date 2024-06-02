import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pubfix/Screen/welcome_screen.dart';
import 'package:pubfix/Screen_Aut/Settings/forward_button.dart';
import 'package:pubfix/Screen_Aut/Settings/setting_item.dart';
import 'package:pubfix/Screen_Aut/Settings/setting_switch.dart';
import 'package:pubfix/Screen_citoyen/profile/edit_screen.dart';
import 'package:pubfix/Screen_citoyen/profile/password_reset.dart';
import 'package:pubfix/global/global_instances.dart';
import 'package:pubfix/global/global_var.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _imageController = TextEditingController();

  bool isDarkMode = false;
  String? _utilisateur;

  Future<void> _fetchData() async {
    try {
      final utilisateurs = await authVMODEL.getUserPhotoFromFirestore();
      setState(() {
        _utilisateur = utilisateurs;
      });
    } catch (error) {
      print(error); // Handle errors appropriately
    }
  }

  String? _userPhotoUrl;
  bool _isLoading = true;

  Future<void> _loadUserPhoto() async {
    try {
      String? photoUrl = await authVMODEL.getUserPhotoFromFirestore();
      setState(() {
        _userPhotoUrl = photoUrl;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement de la photo de l\'utilisateur: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authVM.buildProfileAvatar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserPhoto();
  }

  String title = 'AlertDialog';
  bool tappedYes = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromARGB(255, 14, 189, 148),
          title: const Text(
            'Paramètres',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
              ), // Icône de notification
              onPressed: () {
                // Action à effectuer lors de l'appui sur l'icône de notification
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
                            SizedBox(
                              height: 70,
                              width: 70,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _userPhotoUrl != null
                                    ? NetworkImage(_userPhotoUrl!)
                                    : const AssetImage('assets/images/log.png')
                                        as ImageProvider,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sharefPrefrences!
                                      .getString("name")
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  sharefPrefrences!
                                      .getString("email")
                                      .toString(),
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
                      const SizedBox(height: 20),
                      SettingItem(
                        title: "Mot de passe",
                        icon: Ionicons.lock_closed,
                        bgColor: const Color.fromARGB(255, 193, 211, 189),
                        iconColor: const Color.fromARGB(255, 44, 187, 77),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ChangePasswordScreen(),
                            ),
                          );
                        },
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
                        onTap: () {},
                      ),
                      const SizedBox(height: 20),
                      SettingSwitch(
                        title: "Mode nuit",
                        icon: Ionicons.color_wand_sharp,
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
                        icon: Ionicons.information,
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
                        onTap: () async {
                          final action = await AlertDialogs.yesCancelDialog(
                              context,
                              'Déconnexion',
                              'Êtes-vous sûr de vouloir vous déconnecter ?');
                          if (action == DialogsAction.yes) {
                            setState(() => tappedYes = true);
                          } else {
                            setState(() => tappedYes = false);
                          }

                          /*    authVM.logout();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                          );*/
                        },
                      ),
                    ],
                  ),
                ),
              ),
        // }
        // }),
      ),
    );
  }
}

enum DialogsAction { yes, cancel }

class AlertDialogs {
  static Future<DialogsAction> yesCancelDialog(
    BuildContext context,
    String title,
    String body,
  ) async {
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(DialogsAction.cancel),
              child: const Text(
                'Annuler',
                style: TextStyle(
                    color: Color.fromARGB(255, 39, 222, 169),
                    fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 39, 222, 169),
              ),
              onPressed: () {
                authVM.logout();
                const CircularProgressIndicator();
                Future.delayed(const Duration(seconds: 3));

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                );
              },
              child: const Text(
                'Se déconnecter',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            )
          ],
        );
      },
    );
    return (action != null) ? action : DialogsAction.cancel;
  }
}
