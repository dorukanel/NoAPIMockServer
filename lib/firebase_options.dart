// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyB6O8HchuMflS73Y-DFgwBGt_5bsQwdmHI',
    appId: '1:665024229237:web:2b6dd989a1d8cc25486d3c',
    messagingSenderId: '665024229237',
    projectId: 'noapimockserver',
    authDomain: 'noapimockserver.firebaseapp.com',
    storageBucket: 'noapimockserver.appspot.com',
    measurementId: 'G-8L81HX1S7G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAedNDO_7YQse_AYB8sSizWoyBNWiJDenk',
    appId: '1:665024229237:android:3d4bfd3d42bc5fb7486d3c',
    messagingSenderId: '665024229237',
    projectId: 'noapimockserver',
    storageBucket: 'noapimockserver.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDGPIoWvr0A4cjBS2RnN21wXlXfuwvM6Rw',
    appId: '1:665024229237:ios:38d8365a3e1fa635486d3c',
    messagingSenderId: '665024229237',
    projectId: 'noapimockserver',
    storageBucket: 'noapimockserver.appspot.com',
    iosBundleId: 'com.example.noapimockserver',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDGPIoWvr0A4cjBS2RnN21wXlXfuwvM6Rw',
    appId: '1:665024229237:ios:38d8365a3e1fa635486d3c',
    messagingSenderId: '665024229237',
    projectId: 'noapimockserver',
    storageBucket: 'noapimockserver.appspot.com',
    iosBundleId: 'com.example.noapimockserver',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB6O8HchuMflS73Y-DFgwBGt_5bsQwdmHI',
    appId: '1:665024229237:web:1d4154c4ebb2d5bf486d3c',
    messagingSenderId: '665024229237',
    projectId: 'noapimockserver',
    authDomain: 'noapimockserver.firebaseapp.com',
    storageBucket: 'noapimockserver.appspot.com',
    measurementId: 'G-GSEZR8FL2Y',
  );
}