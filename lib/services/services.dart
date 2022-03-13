import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

abstract class Service {
  //function to upload images to firebase storage and retrieve the url.
  Future<String> uploadImage(Reference ref, Uint8List file) async {
    //todo
    var completer = new Completer();
    completer.complete("Not Implementation");
    return completer.future;
  }
}
