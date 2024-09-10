import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Add other platforms here if needed
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAI_ZjJRdUqUxihQiiNcST0YU6wSa3O8o',
    appId: '1:873895420737:web:76c571751411b9c459b7c0',
    messagingSenderId: '873895420737',
    projectId: 'immo24calculator',
    authDomain: 'immo24calculator.firebaseapp.com',
    storageBucket: 'immo24calculator.appspot.com',
    measurementId: 'G-Q4PK66QSSW',
  );
}
