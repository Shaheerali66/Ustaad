import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBqJOkhXknOEHRNljCvxqZJBXaKaxyTtbg',
    appId: '1:724767300046:web:66b0a33c67319ed6af339f',
    messagingSenderId: '724767300046',
    projectId: 'ustaad-3f94f',
    authDomain: 'ustaad-3f94f.firebaseapp.com',
    storageBucket: 'ustaad-3f94f.firebasestorage.app',
    measurementId: 'G-6RB5XE7XBQ',
  );

  // Note: Only web configuration was provided. 
  // Add iOS/Android options here if compiling for those platforms later.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBqJOkhXknOEHRNljCvxqZJBXaKaxyTtbg',
    appId: '1:724767300046:android:example',
    messagingSenderId: '724767300046',
    projectId: 'ustaad-3f94f',
    storageBucket: 'ustaad-3f94f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBqJOkhXknOEHRNljCvxqZJBXaKaxyTtbg',
    appId: '1:724767300046:ios:example',
    messagingSenderId: '724767300046',
    projectId: 'ustaad-3f94f',
    storageBucket: 'ustaad-3f94f.firebasestorage.app',
    iosBundleId: 'com.example.ustaad',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBqJOkhXknOEHRNljCvxqZJBXaKaxyTtbg',
    appId: '1:724767300046:ios:example',
    messagingSenderId: '724767300046',
    projectId: 'ustaad-3f94f',
    storageBucket: 'ustaad-3f94f.firebasestorage.app',
    iosBundleId: 'com.example.ustaad',
  );
}
