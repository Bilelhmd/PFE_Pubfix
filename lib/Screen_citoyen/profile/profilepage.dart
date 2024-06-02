import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? currentFirebaseUser;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  String userId = 'id'; // Replace with your user ID
  String profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    fetchProfilePicture();
  }

  void fetchProfilePicture() async {
    DocumentSnapshot documentSnapshot =
        await firestore.collection('Users').doc(currentFirebaseUser?.uid).get();
    //  setState(() {
    //     profilePictureUrl = data?['profile_picture']; // Handle potential null value

    // profilePictureUrl = documentSnapshot.data()?['photo'];
    // profilePictureUrl = documentSnapshot.data()['photo'];
    //  });
    if (documentSnapshot.exists) {
      Map<String, dynamic>? data = documentSnapshot.data()
          as Map<String, dynamic>?; // Explicit casting to Map<String, dynamic>
      setState(() {
        profilePictureUrl =
            data?['profile_picture']; // Handle potential null value
      });
    }
  }

  Future<void> changeProfilePicture(String imageUrl) async {
    await firestore.collection('Users').doc(userId).update({
      'photo': imageUrl,
    });
  }

  Future<void> uploadImage() async {
    // Implement your image upload logic here
    // Once uploaded, get the download URL
    String imageUrl = 'your_image_download_url';
    changeProfilePicture(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: profilePictureUrl.isNotEmpty
                  ? NetworkImage(profilePictureUrl)
                  : const AssetImage('assets/default_avatar.jpg')
                      as ImageProvider<Object>,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to page where user can change profile picture
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeProfilePicturePage(
                      uploadImage: uploadImage,
                    ),
                  ),
                );
              },
              child: const Text('Change Profile Picture'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangeProfilePicturePage extends StatelessWidget {
  final Function uploadImage;

  const ChangeProfilePicturePage({super.key, required this.uploadImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Profile Picture'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Trigger image upload and update Firestore
            uploadImage();
            Navigator.pop(context); // Return to profile page
          },
          child: const Text('Upload Image'),
        ),
      ),
    );
  }
}
