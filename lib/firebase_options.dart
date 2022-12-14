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
    apiKey: 'AIzaSyCsTfm7iuCMXxntUgtZ7Lpnhh98gkbh8w4',
    appId: '1:630112467886:web:167b8a56455aa7da9b263f',
    messagingSenderId: '630112467886',
    projectId: 'firstflutter-868ae',
    authDomain: 'firstflutter-868ae.firebaseapp.com',
    storageBucket: 'firstflutter-868ae.appspot.com',
    measurementId: 'G-Z7BYYW5347',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChOcHPGLS7RerBKpwJGQTeFPHxad9mFLw',
    appId: '1:630112467886:android:977e3174ede463329b263f',
    messagingSenderId: '630112467886',
    projectId: 'firstflutter-868ae',
    storageBucket: 'firstflutter-868ae.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBF-agf_JTl9Nmjiyw6UBQ7mw4ECjzsIto',
    appId: '1:630112467886:ios:32879208682acb2e9b263f',
    messagingSenderId: '630112467886',
    projectId: 'firstflutter-868ae',
    storageBucket: 'firstflutter-868ae.appspot.com',
    iosClientId: '630112467886-37r9r6vv8o7cqmcea2vls2j14hess1uh.apps.googleusercontent.com',
    iosBundleId: 'com.example.learningdart',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBF-agf_JTl9Nmjiyw6UBQ7mw4ECjzsIto',
    appId: '1:630112467886:ios:32879208682acb2e9b263f',
    messagingSenderId: '630112467886',
    projectId: 'firstflutter-868ae',
    storageBucket: 'firstflutter-868ae.appspot.com',
    iosClientId: '630112467886-37r9r6vv8o7cqmcea2vls2j14hess1uh.apps.googleusercontent.com',
    iosBundleId: 'com.example.learningdart',
  );
}
