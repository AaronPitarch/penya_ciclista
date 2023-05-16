import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:penya_ciclista/models/ruta_mode.dart';

class RutasService {
  static final CollectionReference rutasCollection = FirebaseFirestore.instance.collection('rutas');

  static Future<List<Ruta>> getAllRutas() async {
    QuerySnapshot snapshot = await rutasCollection.orderBy('fecha', descending: true).get();
    
    return snapshot.docs.map((doc) => Ruta(
      titulo: doc['titulo'],
      descripcion: doc['descripcion'],
      alternativo: doc['alternativo'],
      kilometros: doc['kilometros'],
      desnivel: doc['desnivel'],
      puntos: doc['puntos'],
      imagen: doc['imagen'],
      fecha: doc['fecha'].toDate(),
    )).toList();
  }
}