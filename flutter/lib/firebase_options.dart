// TODO: Run setup-firebase.sh

// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members, do_not_use_environment, constant_identifier_names
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

const flavorName = String.fromEnvironment('flavor');

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (flavorName.isEmpty) {
      throw UnsupportedError(
        'No flavor specified. Please specify a flavor with dart-define-from-file.',
      );
    }

    if (kIsWeb) {
      throw UnsupportedError(
        'Flavor $flavorName does not support Web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'Flavor $flavorName does not support Android.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Flavor $flavorName does not support iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
      // ignore: no_default_cases
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
