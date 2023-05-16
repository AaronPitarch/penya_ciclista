import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class GaleriaPage extends StatefulWidget {
  const GaleriaPage({super.key});

  @override
  State<GaleriaPage> createState() => _GaleriaPageState();
}

class _GaleriaPageState extends State<GaleriaPage> {

  final ImagePicker _imagePicker = ImagePicker();
  final firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;

  Future<void> _mostrarDialogoGuardarImagen(String imagePath) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Guardar imagen'),
          content: const Text('¿Deseas guardar la imagen en la galería interna o en la nube?'),
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
    final firebase_storage.Reference ref = _storage.ref().child('imagenes/$fileName');
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
      } else {
        // Error al subir la imagen
        print('Error al subir la imagen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria de Fotos'),
        centerTitle: true,
      ),



      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final image = await _imagePicker.pickImage(source: ImageSource.camera);
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