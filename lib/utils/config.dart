import 'package:firebase_core/firebase_core.dart';

class Config {
  static initFirebase() async {
    await Firebase.initializeApp(  // Replace with actual values
      options: FirebaseOptions(
        apiKey: "XXX",
        appId: "XXX",
        messagingSenderId: "XXX",
        projectId: "XXX",
      ));
  }
}