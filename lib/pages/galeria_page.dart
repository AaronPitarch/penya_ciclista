import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grid_staggered_lite/grid_staggered_lite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:penya_ciclista/services/galeria_service.dart';

class GaleriaPage extends StatefulWidget {
  const GaleriaPage({super.key});

  @override
  State<GaleriaPage> createState() => _GaleriaPageState();
}

class _GaleriaPageState extends State<GaleriaPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final GaleriaService _galeriaService = GaleriaService();
  List<String> _imageUrls = [];
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _cargarImagenes();
  }

  Future<void> _mostrarDialogoGuardarImagen(String imagePath) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Guardar imagen'),
          content: const Text(
              '¿Deseas guardar la imagen en la galería interna o en la nube?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Galería interna'),
              onPressed: () {
                Navigator.of(context).pop();
                //_guardarEnGaleriaInterna(imagePath); --> para guardar en galeria interna
              },
            ),
            TextButton(
              child: const Text('Nube'),
              onPressed: () {
                Navigator.of(context).pop();
                _subirANube(imagePath);
              },
            ),
          ],
        );
      },
    );
  }

/* Este seria el codigo para guardar la imagen en la galeria interna

  Future<void> _guardarEnGaleriaInterna(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(imagePath);
    final savedImagePath = path.join(directory.path, fileName);
    await File(imagePath).copy(savedImagePath);
    // Aquí puedes mostrar un mensaje de éxito o realizar otras acciones necesarias
  }
  */

  Future<void> _subirANube(String imagePath) async {
    final fileName = path.basename(imagePath);
    final firebase_storage.Reference ref =
        _storage.ref().child('imagenes/$fileName');
    final metadata = firebase_storage.SettableMetadata(
      contentType: 'image/jpeg',
    );
    final uploadTask = ref.putFile(File(imagePath), metadata);
    final snapshot = await uploadTask.whenComplete(() {});
    if (snapshot.state == firebase_storage.TaskState.success) {
      // Imagen subida exitosamente
      print('Imagen subida correctamente');
      // Obtener la URL de descarga de la imagen
      final downloadUrl = await ref.getDownloadURL();
      print('URL de descarga: $downloadUrl');
      // Cargar imagenes actualizadas
      await _cargarImagenes();
    } else {
      // Error al subir la imagen
      print('Error al subir la imagen');
    }
  }

  Future<void> _cargarImagenes() async {
    final imageUrls = await _galeriaService.obtenerImagenes();
    setState(() {
      _imageUrls = imageUrls;
    });
  }

  void _mostrarImagenAmpliada(String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria de Fotos'),
        centerTitle: true,
      ),
      body: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        itemCount: _imageUrls.length,
        itemBuilder: (BuildContext context, int index) {
          final imageUrl = _imageUrls[index];
          return GestureDetector(
            onTap: () {
              _mostrarImagenAmpliada(imageUrl);
            },
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          );
        },
        staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final image =
              await _imagePicker.pickImage(source: ImageSource.camera);
          if (image != null) {
            await _mostrarDialogoGuardarImagen(image.path);
          }
        },
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
