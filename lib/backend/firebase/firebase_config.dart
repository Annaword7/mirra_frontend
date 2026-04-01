import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyABC1CRfxwNk17k1aOiYAcIEB0ZxD2sCiA",
            authDomain: "mirra-9c10a.firebaseapp.com",
            projectId: "mirra-9c10a",
            storageBucket: "mirra-9c10a.firebasestorage.app",
            messagingSenderId: "857864316034",
            appId: "1:857864316034:web:1e502b0936b1bdd003809b",
            measurementId: "G-M7KMC8KBHL"));
  } else {
    await Firebase.initializeApp();
  }
}
