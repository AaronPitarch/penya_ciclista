import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class GaleriaService {
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  Future<List<String>> obtenerImagenes() async {
    final ref = _storage.ref().child('imagenes');
    final result = await ref.listAll();
    final imageUrls = <String>[];

    for (final item in result.items) {
      final url = await item.getDownloadURL();
      imageUrls.add(url);
    }

    return imageUrls;
  }
}