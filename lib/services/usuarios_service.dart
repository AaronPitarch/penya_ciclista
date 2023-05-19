import 'package:penya_ciclista/models/user_model.dart';

// Importaciones de firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsuariosService {
  static final CollectionReference usuariosCollection = FirebaseFirestore.instance.collection('usuarios');

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