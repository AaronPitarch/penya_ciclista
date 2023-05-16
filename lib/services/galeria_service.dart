import 'package:firebase_storage/firebase_storage.dart';

class GaleriaService {
  final Reference storageReference = FirebaseStorage.instance.ref().child('imagenes');

  Future<List<String>> obtenerImagenes() async {
    List<String> listaImagenes = [];

    try {
      final ListResult listResult = await storageReference.listAll();
      final List<Reference> imageRef = listResult.items;

      for (final ref in imageRef) {
        final imageUrl = await ref.getDownloadURL();
        listaImagenes.add(imageUrl);
      }

    } catch (e) {
      print('Error al obtener las imagenes: $e');
    }

    return listaImagenes;
  }
}