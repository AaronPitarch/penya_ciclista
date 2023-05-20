import 'dart:io';

import 'package:penya_ciclista/models/user_model.dart';

// Importaciones de firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UsuariosService {
  static final CollectionReference usuariosCollection = FirebaseFirestore.instance.collection('usuarios');
  //static final CollectionReference perfilUsuariosCollection = FirebaseFirestore.instance.collection('perfilUsuarios');

  static Future<List<Usuario>> todosUsuarios() async {
    QuerySnapshot snapshot = await usuariosCollection.orderBy('puntos', descending: true).get();
    return snapshot.docs.map((e) => Usuario(
      nombre: e['nombre'],
      puntos: e['puntos'],
      imagen: e['imagen'],
      //email: e['email']
    )).toList();
  }
}

class ImageUploadService {
  static Future<String> uploadImageToStorage(String imagePath, String userId) async {
    try {
      File imageFile = File(imagePath);
      String fileName = 'user_images/$userId.jpg';

      firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref().child(fileName);
      firebase_storage.UploadTask uploadTask = storageRef.putFile(imageFile);
      firebase_storage.TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      // Manejar el error aquí
      throw e;
    }
  }
}