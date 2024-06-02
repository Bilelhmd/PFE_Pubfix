import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pubfix/Model/Autorite/Autorite_model.dart';
import 'package:pubfix/ViewModel/Autorite/Autorite_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen_Aut extends StatefulWidget {
  const ProfileScreen_Aut({super.key});

  @override
  State<ProfileScreen_Aut> createState() => _ProfileScreen_AutState();
}

class _ProfileScreen_AutState extends State<ProfileScreen_Aut> {
  autoritemodellist? autorite;

  @override
  void initState() {
    super.initState();
    // Load autorite details from Firestore when the widget initializes
    _loadAutoriteDetails();
  }

  Future<void> _loadAutoriteDetails() async {
    final firestoreService = FirestoreService();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Retrieve the displayName, which can be null
      final displayName = user.displayName;
      if (displayName != null) {
        // Retrieve autorite details only if displayName is not null
        final autoriteFromFirestore =
            await firestoreService.getAutoriteByName(displayName);
        setState(() {
          autorite = autoriteFromFirestore;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 189, 148),
        elevation: 0.0,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: autorite != null
          ? SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 40,
                    ),
                    CircleAvatar(
                      backgroundImage: AssetImage(autorite!.image),
                      radius: 40.0,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      autorite!.nom,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      autorite!.phone,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      autorite!.email,
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'tel:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 16),
                          child: Column(
                            children: <Widget>[
                              const Text(''),
                              Text(autorite!.password),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Ville:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 0, 16, 16),
                          child: Text('Medenine'),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
