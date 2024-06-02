import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pubfix/Screen/Splash_Screen.dart';
import 'package:pubfix/firebase_options.dart';
import 'package:pubfix/global/global_var.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Handler pour les messages en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharefPrefrences = await SharedPreferences.getInstance();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PubFix.',
      theme: ThemeData(
        brightness: Brightness.light,
        //   textTheme: GoogleFonts.soraTextTheme(),
        useMaterial3: true,
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen(),
    );
  }
}
