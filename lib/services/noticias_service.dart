import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:penya_ciclista/models/noticias_model.dart';

class NoticiasService {
  static final CollectionReference noticiasCollection = FirebaseFirestore.instance.collection('noticias');

  static Future<List<Noticia>> getNoticias() async {
    QuerySnapshot snapshot = await noticiasCollection.orderBy('fecha', descending: true).get();
    return snapshot.docs.map((doc) => Noticia(
      titulo: doc['titulo'],
      descripcion: doc['descripcion'],
      imagen: doc['imagen'],
      fecha: doc['fecha'].toDate(),
    )).toList();
  }
}