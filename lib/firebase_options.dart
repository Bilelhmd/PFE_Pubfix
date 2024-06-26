// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDCKTAU1xUbl_J3Rbdv4hTuj9FrNjyBvpk',
    appId: '1:622298064039:web:c015e985b61f4766666782',
    messagingSenderId: '622298064039',
    projectId: 'pubfix-2aa04',
    authDomain: 'pubfix-2aa04.firebaseapp.com',
    storageBucket: 'pubfix-2aa04.appspot.com',
    measurementId: 'G-30KDFNYEND',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB4pIQY8WPmXx-nf1KnN5sT8tAUKmY7Bc8',
    appId: '1:622298064039:android:94eccb1f378e041f666782',
    messagingSenderId: '622298064039',
    projectId: 'pubfix-2aa04',
    storageBucket: 'pubfix-2aa04.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBNIXq1m0lVlPouZDOkazl4I6I_NVePWls',
    appId: '1:622298064039:ios:835838bb424b3eb7666782',
    messagingSenderId: '622298064039',
    projectId: 'pubfix-2aa04',
    storageBucket: 'pubfix-2aa04.appspot.com',
    iosBundleId: 'com.example.pubfix',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBNIXq1m0lVlPouZDOkazl4I6I_NVePWls',
    appId: '1:622298064039:ios:c8e56c33d6d46b20666782',
    messagingSenderId: '622298064039',
    projectId: 'pubfix-2aa04',
    storageBucket: 'pubfix-2aa04.appspot.com',
    iosBundleId: 'com.example.pubfix.RunnerTests',
  );
}
