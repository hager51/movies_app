import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for android.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqyotFEx2yKT1OdpVMgPF6K25CMYZZsig',
    appId: '1:882925374156:android:10862f8d9b3cacf03b9069',
    messagingSenderId: '882925374156',
    projectId: 'movies-40beb',
    storageBucket: 'movies-40beb.firebasestorage.app',
  );
}