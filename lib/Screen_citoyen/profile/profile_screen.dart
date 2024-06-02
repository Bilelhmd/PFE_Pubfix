import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pubfix/global/global_var.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /* int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // **Ajoutez votre code de navigation ici**
    if (index == 0) {
      // Accédez à la page d'accueil
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } else if (index == 2) {
      // Accédez à la page de profil
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    //  User? currenFirebaseUser;
    return Scaffold(
      /*    appBar: AppBar(
        title: Text("PubFix."),
      ),*/
      //   backgroundColor: Colors.white,
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 40,
                  ),
                  const Center(
                    child: CircleAvatar(
                      backgroundImage: AssetImage('images/profile.png'),
                      radius: 40.0,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    sharefPrefrences!.getString("name").toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    sharefPrefrences!.getString("phone").toString(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    sharefPrefrences!.getString("email").toString(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Address:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 16),
                        child: Column(
                          children: <Widget>[
                            const Text('adresse 1'),
                            Text(sharefPrefrences!
                                .getString("password")
                                .toString()),
                            Text(
                                sharefPrefrences!.getString("role").toString()),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCard(String title, int value, int goal, Color color) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            '$value',
            style: GoogleFonts.poppins(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5.0),
        ],
      ),
    );
  }

  Widget _buildMacroCard(String title, int value, String unit) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey.shade200,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            '$value$unit',
            style: GoogleFonts.poppins(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
