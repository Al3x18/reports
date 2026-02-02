// Firebase options loaded from keys.env (see keys.env.example).
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'package:reports/utils/env_loader.dart';

/// Default [FirebaseOptions] from env (keys.env). Used by Firebase.initializeApp.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: getEnv('FIREBASE_ANDROID_API_KEY'),
        appId: getEnv('FIREBASE_ANDROID_APP_ID'),
        messagingSenderId: getEnv('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: getEnv('FIREBASE_PROJECT_ID'),
        databaseURL: getEnv('FIREBASE_DATABASE_URL'),
        storageBucket: getEnv('FIREBASE_STORAGE_BUCKET'),
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: getEnv('FIREBASE_IOS_API_KEY'),
        appId: getEnv('FIREBASE_IOS_APP_ID'),
        messagingSenderId: getEnv('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: getEnv('FIREBASE_PROJECT_ID'),
        databaseURL: getEnv('FIREBASE_DATABASE_URL'),
        storageBucket: getEnv('FIREBASE_STORAGE_BUCKET'),
        iosBundleId: getEnv('FIREBASE_IOS_BUNDLE_ID'),
      );
}
